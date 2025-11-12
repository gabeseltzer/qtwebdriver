# WebDriver Qt Extension Libraries

# Helper function to run Qt moc on headers
function(qt_wrap_moc output_var)
    set(moc_files "")
    foreach(header ${ARGN})
        get_filename_component(basename ${header} NAME_WE)
        set(moc_output ${CMAKE_CURRENT_BINARY_DIR}/moc_${basename}.cc)
        add_custom_command(
            OUTPUT ${moc_output}
            COMMAND ${QT_MOC_EXECUTABLE} ${header} -o ${moc_output}
            DEPENDS ${header}
            COMMENT "Running moc on ${header}"
        )
        list(APPEND moc_files ${moc_output})
    endforeach()
    set(${output_var} ${moc_files} PARENT_SCOPE)
endfunction()

# ============================================================================
# WebDriver_extension_qt_base
# ============================================================================

set(WEBDRIVER_QT_BASE_SOURCES
    q_content_type_resolver.cc
    q_view_runner.cc
    q_proxy_parser.cc
    q_key_converter.cc
    q_session_lifecycle_actions.cc
    widget_view_util.cc
    common_util.cc
    widget_view_handle.cc
    widget_element_handle.cc
    q_view_executor.cc
    widget_view_creator.cc
    widget_view_executor.cc
    widget_view_enumerator.cc
    widget_view_visualizer.cc
    shutdown_command.cc
    q_event_filter.cc
    uinput_manager.cc
    ${CMAKE_SOURCE_DIR}/src/vnc/vncclient.cc
    ${CMAKE_SOURCE_DIR}/src/vnc/vncserverparameters.cc
    vnc_event_dispatcher.cc
    wd_event_dispatcher.cc
    uinput_event_dispatcher.cc
    ${CMAKE_SOURCE_DIR}/src/third_party/des/d3des.c
)

# MOC headers for qt_base
set(WEBDRIVER_QT_BASE_MOC_HEADERS
    ${CMAKE_SOURCE_DIR}/inc/extension_qt/q_view_runner.h
    ${CMAKE_CURRENT_SOURCE_DIR}/q_event_filter.h
    ${CMAKE_SOURCE_DIR}/inc/extension_qt/vncclient.h
)

qt_wrap_moc(WEBDRIVER_QT_BASE_MOC_SOURCES ${WEBDRIVER_QT_BASE_MOC_HEADERS})

add_library(WebDriver_extension_qt_base STATIC
    ${WEBDRIVER_QT_BASE_SOURCES}
    ${WEBDRIVER_QT_BASE_MOC_SOURCES}
)

target_include_directories(WebDriver_extension_qt_base
    PUBLIC
        ${CMAKE_SOURCE_DIR}/inc
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(WebDriver_extension_qt_base
    PUBLIC
        WebDriver_core
        ${QT_LIBRARIES}
)

# Qt4-specific dependency
if(NOT QT5 AND NOT QT6)
    target_link_libraries(WebDriver_extension_qt_base PRIVATE mimetypes-qt4)
endif()

# ============================================================================
# WebDriver_extension_qt_web
# ============================================================================

if(WD_CONFIG_WEBKIT)
    set(WEBDRIVER_QT_WEB_SOURCES
        web_view_creator.cc
        web_view_executor.cc
        web_view_enumerator.cc
        web_view_visualizer.h
        web_view_visualizer.cc
        qwebviewext.cc
        web_view_util.cc
        web_view_util.h
        qwebkit_proxy.cc
        qwebkit_proxy.h
        qnetwork_access_manager_tracer.cc
        graphics_web_view_handle.cc
        graphics_web_view_enumerator.cc
        graphics_web_view_executor.cc
        ${CMAKE_SOURCE_DIR}/src/third_party/webdriver/atoms.cc
    )

    set(WEBDRIVER_QT_WEB_MOC_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/web_view_visualizer.h
        ${CMAKE_SOURCE_DIR}/inc/extension_qt/qwebviewext.h
        ${CMAKE_CURRENT_SOURCE_DIR}/qwebkit_proxy.h
        ${CMAKE_SOURCE_DIR}/inc/extension_qt/qnetwork_access_manager_tracer.h
    )

    qt_wrap_moc(WEBDRIVER_QT_WEB_MOC_SOURCES ${WEBDRIVER_QT_WEB_MOC_HEADERS})

    add_library(WebDriver_extension_qt_web STATIC
        ${WEBDRIVER_QT_WEB_SOURCES}
        ${WEBDRIVER_QT_WEB_MOC_SOURCES}
    )

    target_include_directories(WebDriver_extension_qt_web
        PUBLIC
            ${CMAKE_SOURCE_DIR}/inc
        PRIVATE
            ${CMAKE_SOURCE_DIR}/src
            ${CMAKE_CURRENT_BINARY_DIR}
    )

    target_link_libraries(WebDriver_extension_qt_web
        PUBLIC
            WebDriver_core
            WebDriver_extension_qt_base
            ${QT_LIBRARIES}
    )

    if(QT5)
        target_link_libraries(WebDriver_extension_qt_web PUBLIC Qt5::WebKit Qt5::WebKitWidgets)
    endif()
endif()

# ============================================================================
# WebDriver_extension_qt_quick
# ============================================================================

if(WD_CONFIG_QUICK)
    if(QT5 OR QT6)
        # Qt5/Qt6 - Quick2
        set(WEBDRIVER_QT_QUICK_SOURCES
            qwindow_view_handle.cc
            qwindow_view_executor.cc
            quick2_view_creator.cc
            quick2_view_enumerator.cc
            quick2_view_executor.cc
            qml_view_util.cc
            qml_objname_util.h
            qml_objname_util.cc
        )

        set(WEBDRIVER_QT_QUICK_MOC_HEADERS
            ${CMAKE_CURRENT_SOURCE_DIR}/qml_objname_util.h
        )
    else()
        # Qt4 - Quick1
        set(WEBDRIVER_QT_QUICK_SOURCES
            qml_view_creator.cc
            qml_view_enumerator.cc
            qml_view_executor.cc
            qml_view_util.cc
            qml_objname_util.h
            qml_objname_util.cc
        )

        set(WEBDRIVER_QT_QUICK_MOC_HEADERS
            ${CMAKE_CURRENT_SOURCE_DIR}/qml_objname_util.h
        )
    endif()

    qt_wrap_moc(WEBDRIVER_QT_QUICK_MOC_SOURCES ${WEBDRIVER_QT_QUICK_MOC_HEADERS})

    add_library(WebDriver_extension_qt_quick STATIC
        ${WEBDRIVER_QT_QUICK_SOURCES}
        ${WEBDRIVER_QT_QUICK_MOC_SOURCES}
    )

    target_include_directories(WebDriver_extension_qt_quick
        PUBLIC
            ${CMAKE_SOURCE_DIR}/inc
        PRIVATE
            ${CMAKE_SOURCE_DIR}/src
            ${CMAKE_CURRENT_BINARY_DIR}
    )

    target_link_libraries(WebDriver_extension_qt_quick
        PUBLIC
            WebDriver_core
            WebDriver_extension_qt_base
            ${QT_LIBRARIES}
    )
endif()

# ============================================================================
# WebDriver_extension_qt_quick_web
# ============================================================================

if(WD_CONFIG_QUICK)
    if(QT5 OR QT6)
        # Qt5/Qt6 - Quick2
        add_library(WebDriver_extension_qt_quick_web STATIC
            ${CMAKE_SOURCE_DIR}/src/webdriver/dummy.cc
        )
    else()
        # Qt4
        set(WEBDRIVER_QT_QUICK_WEB_SOURCES
            declarative_item_view_handle.cc
            qdeclarativewebview.cc
            qml_web_view_enumerator.cc
            qml_web_view_executor.cc
        )

        set(WEBDRIVER_QT_QUICK_WEB_MOC_HEADERS
            ${CMAKE_SOURCE_DIR}/inc/extension_qt/qdeclarativewebview.h
        )

        qt_wrap_moc(WEBDRIVER_QT_QUICK_WEB_MOC_SOURCES ${WEBDRIVER_QT_QUICK_WEB_MOC_HEADERS})

        add_library(WebDriver_extension_qt_quick_web STATIC
            ${WEBDRIVER_QT_QUICK_WEB_SOURCES}
            ${WEBDRIVER_QT_QUICK_WEB_MOC_SOURCES}
        )
    endif()

    target_include_directories(WebDriver_extension_qt_quick_web
        PUBLIC
            ${CMAKE_SOURCE_DIR}/inc
        PRIVATE
            ${CMAKE_SOURCE_DIR}/src
            ${CMAKE_CURRENT_BINARY_DIR}
    )

    target_link_libraries(WebDriver_extension_qt_quick_web
        PUBLIC
            WebDriver_core
            WebDriver_extension_qt_base
    )
endif()

# ============================================================================
# Shared Libraries (Linux only)
# ============================================================================

if(LINUX)
    add_library(WebDriver_extension_qt_base_shared SHARED)
    target_link_libraries(WebDriver_extension_qt_base_shared PUBLIC WebDriver_extension_qt_base)
    set_target_properties(WebDriver_extension_qt_base_shared PROPERTIES
        OUTPUT_NAME WebDriver_extension_qt_base
    )

    if(WD_CONFIG_WEBKIT)
        add_library(WebDriver_extension_qt_web_shared SHARED)
        target_link_libraries(WebDriver_extension_qt_web_shared PUBLIC WebDriver_extension_qt_web)
        set_target_properties(WebDriver_extension_qt_web_shared PROPERTIES
            OUTPUT_NAME WebDriver_extension_qt_web
        )
    endif()

    if(WD_CONFIG_QUICK)
        add_library(WebDriver_extension_qt_quick_shared SHARED)
        target_link_libraries(WebDriver_extension_qt_quick_shared PUBLIC WebDriver_extension_qt_quick)
        set_target_properties(WebDriver_extension_qt_quick_shared PROPERTIES
            OUTPUT_NAME WebDriver_extension_qt_quick
        )

        add_library(WebDriver_extension_qt_quick_web_shared SHARED)
        target_link_libraries(WebDriver_extension_qt_quick_web_shared PUBLIC WebDriver_extension_qt_quick_web)
        set_target_properties(WebDriver_extension_qt_quick_web_shared PROPERTIES
            OUTPUT_NAME WebDriver_extension_qt_quick_web
        )
    endif()
endif()

# ============================================================================
# Installation
# ============================================================================

install(TARGETS WebDriver_extension_qt_base
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if(WD_CONFIG_WEBKIT)
    install(TARGETS WebDriver_extension_qt_web
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
    )
endif()

if(WD_CONFIG_QUICK)
    install(TARGETS WebDriver_extension_qt_quick WebDriver_extension_qt_quick_web
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
    )
endif()

if(LINUX)
    install(TARGETS WebDriver_extension_qt_base_shared
        LIBRARY DESTINATION lib
    )

    if(WD_CONFIG_WEBKIT AND TARGET WebDriver_extension_qt_web_shared)
        install(TARGETS WebDriver_extension_qt_web_shared
            LIBRARY DESTINATION lib
        )
    endif()

    if(WD_CONFIG_QUICK)
        if(TARGET WebDriver_extension_qt_quick_shared)
            install(TARGETS WebDriver_extension_qt_quick_shared
                LIBRARY DESTINATION lib
            )
        endif()

        if(TARGET WebDriver_extension_qt_quick_web_shared)
            install(TARGETS WebDriver_extension_qt_quick_web_shared
                LIBRARY DESTINATION lib
            )
        endif()
    endif()
endif()
