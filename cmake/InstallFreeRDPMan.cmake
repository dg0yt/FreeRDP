include(GNUInstallDirs)
include(FindDocBookXSL)

function(install_freerdp_man manpage section)
	if(WITH_MANPAGES)
		install(FILES ${manpage} DESTINATION ${CMAKE_INSTALL_MANDIR}/man${section})
	endif()
endfunction()

function(generate_and_install_freerdp_man_from_xml template manpage dependencies)
	if(WITH_MANPAGES)
		find_program(XSLTPROC_EXECUTABLE NAMES xsltproc REQUIRED)
		if (NOT DOCBOOKXSL_FOUND)
			message(FATAL_ERROR "docbook xsl not found but required for manpage generation")
		endif()

		# We need the variable ${MAN_TODAY} to contain the current date in ISO
		# format to replace it in the configure_file step.
		include(today)

		TODAY(MAN_TODAY)

		configure_file(${template}.xml.in ${manpage}.xml @ONLY IMMEDIATE)

		foreach(DEP IN LISTS dependencies)
			set(SRC ${CMAKE_CURRENT_SOURCE_DIR}/${DEP}.in)
			set(DST ${CMAKE_CURRENT_BINARY_DIR}/${DEP})

			if (EXISTS ${SRC})
				message("generating ${DST} from ${SRC}")
				configure_file(${SRC} ${DST} @ONLY IMMEDIATE)
			else()
				message("using ${DST} from ${SRC}")
			endif()
		endforeach()

		add_custom_command(
					OUTPUT ${manpage}
					COMMAND ${CMAKE_BINARY_DIR}/client/common/man/generate_argument_docbook
					COMMAND ${XSLTPROC_EXECUTABLE} --path "${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}" ${DOCBOOKXSL_DIR}/manpages/docbook.xsl ${manpage}.xml
					WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
					DEPENDS
						${CMAKE_CURRENT_BINARY_DIR}/${manpage}.xml
						generate_argument_docbook
						${template}.xml.in
					)

		add_custom_target(
			${manpage}.manpage ALL
			DEPENDS
				${manpage}
			)
		install_freerdp_man(${CMAKE_CURRENT_BINARY_DIR}/${manpage} 1)
	endif()
endfunction()
