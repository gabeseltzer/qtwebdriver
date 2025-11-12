# WebDriver Test Executables

# Helper function for Qt moc
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
# test_widgets library
# ============================================================================

set(TEST_WIDGETS_SOURCES
    Headers.h
    Samples.h
    ClickTest.cc
    ClickTest.h
    ClickScrollingTest.cc
    ClickScrollingTest.h
    ClickScrollingTest.ui
    WindowTest.cc
    WindowTest.h
    FindingTest.cc
    FindingTest.h
    CoordinatesTest.cc
    CoordinatesTest.h
    ElementAttributeTest.cc
    ElementAttributeTest.h
    ElementSelectingTest.cc
    ElementSelectingTest.h
    ElementSelectingTest.ui
    TypingTest.cc
    TypingTest.h
    BasicKeyboardInterfaceTest.cc
    BasicKeyboardInterfaceTest.h
    TextHandlingTest.cc
    TextHandlingTest.h
    FormHandlingTest.cc
    FormHandlingTest.h
    img.xpm
    XPathElementFindingTest.cc
    XPathElementFindingTest.h
    StaleElementReferenceTest.cc
    StaleElementReferenceTest.h
    VisibilityTest.cc
    VisibilityTest.h
    RestyledLabel.cc
    RestyledLabel.h
    DragableWidget.cc
    DragableWidget.h
    BasicMouseInterfaceTest.cc
    BasicMouseInterfaceTest.h
    TouchTest.cc
    TouchTest.h
    MenuTest.cc
    MenuTest.h
)

set(TEST_WIDGETS_MOC_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/ClickTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/ClickScrollingTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/WindowTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/FindingTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/CoordinatesTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/ElementAttributeTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/ElementSelectingTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/TypingTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/BasicKeyboardInterfaceTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/TextHandlingTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/FormHandlingTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/XPathElementFindingTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/StaleElementReferenceTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/VisibilityTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/RestyledLabel.h
    ${CMAKE_CURRENT_SOURCE_DIR}/DragableWidget.h
    ${CMAKE_CURRENT_SOURCE_DIR}/BasicMouseInterfaceTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/TouchTest.h
    ${CMAKE_CURRENT_SOURCE_DIR}/MenuTest.h
)

# Platform-specific sources
if(QT5 AND WD_CONFIG_PLAYER)
    list(APPEND TEST_WIDGETS_SOURCES
        VideoTest.h
        VideoTest.cc
    )
    list(APPEND TEST_WIDGETS_MOC_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/VideoTest.h
    )
endif()

if(NOT ANDROID AND NOT QT5 AND NOT QT6)
    list(APPEND TEST_WIDGETS_SOURCES
        WindowWithDeclarativeViewTest.cc
        WindowWithDeclarativeViewTest.h
    )
    list(APPEND TEST_WIDGETS_MOC_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/WindowWithDeclarativeViewTest.h
    )
endif()

qt_wrap_moc(TEST_WIDGETS_MOC_SOURCES ${TEST_WIDGETS_MOC_HEADERS})

add_library(test_widgets STATIC
    ${TEST_WIDGETS_SOURCES}
    ${TEST_WIDGETS_MOC_SOURCES}
)

target_include_directories(test_widgets
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
    PRIVATE
        ${CMAKE_SOURCE_DIR}/inc
        ${CMAKE_SOURCE_DIR}/src
)

target_link_libraries(test_widgets
    PUBLIC
        ${QT_LIBRARIES}
)

# Add multimedia libraries for Qt6
if(QT6)
    find_package(Qt6 COMPONENTS Multimedia MultimediaWidgets PrintSupport Sql OpenGL)
    if(Qt6_FOUND)
        target_link_libraries(test_widgets PUBLIC
            Qt6::Multimedia
            Qt6::MultimediaWidgets
            Qt6::PrintSupport
            Qt6::Sql
            Qt6::OpenGL
        )
    endif()
    
    if(WD_CONFIG_QUICK)
        find_package(Qt6 COMPONENTS Positioning)
        if(Qt6Positioning_FOUND)
            target_link_libraries(test_widgets PUBLIC Qt6::Positioning)
        endif()
    endif()
elseif(QT5)
    find_package(Qt5 COMPONENTS Multimedia MultimediaWidgets PrintSupport Sql OpenGL Sensors)
    if(Qt5_FOUND)
        target_link_libraries(test_widgets PUBLIC
            Qt5::Multimedia
            Qt5::MultimediaWidgets
            Qt5::PrintSupport
            Qt5::Sql
            Qt5::OpenGL
            Qt5::Sensors
        )
    endif()
    
    if(WD_CONFIG_QUICK)
        find_package(Qt5 COMPONENTS Positioning)
        if(Qt5Positioning_FOUND)
            target_link_libraries(test_widgets PUBLIC Qt5::Positioning)
        endif()
    endif()
endif()

# ============================================================================
# test_WD_hybrid (with WebKit)
# ============================================================================

if(WD_CONFIG_WEBKIT)
    set(TEST_WD_HYBRID_SOURCES
        main.cc
        WindowWithEmbeddedViewTest.cc
        WindowWithEmbeddedViewTest.h
        WidgetAndWebViewTest.cc
        WidgetAndWebViewTest.h
        GraphicsWebViewTest.cc
        GraphicsWebViewTest.h
    )

    set(TEST_WD_HYBRID_MOC_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/WindowWithEmbeddedViewTest.h
        ${CMAKE_CURRENT_SOURCE_DIR}/WidgetAndWebViewTest.h
        ${CMAKE_CURRENT_SOURCE_DIR}/GraphicsWebViewTest.h
    )

    # Qt4-specific sources
    if(NOT QT5 AND NOT QT6)
        list(APPEND TEST_WD_HYBRID_SOURCES
            WindowWithSeparatedDeclarativeAndWebViewsTest.cc
            WindowWithSeparatedDeclarativeAndWebViewsTest.h
        )
        list(APPEND TEST_WD_HYBRID_MOC_HEADERS
            ${CMAKE_CURRENT_SOURCE_DIR}/WindowWithSeparatedDeclarativeAndWebViewsTest.h
        )
    endif()

    qt_wrap_moc(TEST_WD_HYBRID_MOC_SOURCES ${TEST_WD_HYBRID_MOC_HEADERS})

    add_executable(test_WD_hybrid
        ${TEST_WD_HYBRID_SOURCES}
        ${TEST_WD_HYBRID_MOC_SOURCES}
    )

    set_target_properties(test_WD_hybrid PROPERTIES
        OUTPUT_NAME WebDriver
    )

    target_compile_definitions(test_WD_hybrid PRIVATE WD_ENABLE_WEB_VIEW=1)

    target_link_libraries(test_WD_hybrid
        PRIVATE
            chromium_base
            WebDriver_core
            WebDriver_extension_qt_base
            WebDriver_extension_qt_web
            test_widgets
    )

    if(WD_CONFIG_QUICK)
        target_link_libraries(test_WD_hybrid PRIVATE
            WebDriver_extension_qt_quick
            WebDriver_extension_qt_quick_web
        )
    else()
        target_compile_definitions(test_WD_hybrid PRIVATE QT_NO_QML)
    endif()

    # Add WebKit libraries
    if(QT5)
        target_link_libraries(test_WD_hybrid PRIVATE Qt5::WebKit Qt5::WebKitWidgets)
    elseif(QT6)
        target_link_libraries(test_WD_hybrid PRIVATE Qt6::WebEngineWidgets)
    endif()

    # Add mongoose if not built in
    if(NOT WD_BUILD_MONGOOSE)
        target_sources(test_WD_hybrid PRIVATE ${CMAKE_SOURCE_DIR}/src/third_party/mongoose/mongoose.c)
    endif()

    install(TARGETS test_WD_hybrid
        RUNTIME DESTINATION bin
    )
endif()

# ============================================================================
# test_WD_hybrid_noWebkit (without WebKit)
# ============================================================================

add_executable(test_WD_hybrid_noWebkit main.cc)

set_target_properties(test_WD_hybrid_noWebkit PROPERTIES
    OUTPUT_NAME WebDriver_noWebkit
)

target_link_libraries(test_WD_hybrid_noWebkit
    PRIVATE
        chromium_base
        WebDriver_core
        WebDriver_extension_qt_base
        test_widgets
)

if(WD_CONFIG_QUICK)
    target_link_libraries(test_WD_hybrid_noWebkit PRIVATE WebDriver_extension_qt_quick)
else()
    target_compile_definitions(test_WD_hybrid_noWebkit PRIVATE QT_NO_QML)
endif()

if(NOT WD_BUILD_MONGOOSE)
    target_sources(test_WD_hybrid_noWebkit PRIVATE ${CMAKE_SOURCE_DIR}/src/third_party/mongoose/mongoose.c)
endif()

install(TARGETS test_WD_hybrid_noWebkit
    RUNTIME DESTINATION bin
)

# ============================================================================
# test_WD_hybrid_noWebkit_with_shared_libs (Linux only)
# ============================================================================

if(LINUX)
    add_executable(test_WD_hybrid_noWebkit_with_shared_libs main.cc)

    set_target_properties(test_WD_hybrid_noWebkit_with_shared_libs PROPERTIES
        OUTPUT_NAME WebDriver_noWebkit_sharedLibs
    )

    target_link_libraries(test_WD_hybrid_noWebkit_with_shared_libs
        PRIVATE
            chromium_base_shared
            WebDriver_core_shared
            WebDriver_extension_qt_base_shared
            test_widgets
    )

    if(WD_CONFIG_QUICK)
        target_link_libraries(test_WD_hybrid_noWebkit_with_shared_libs PRIVATE WebDriver_extension_qt_quick)
    else()
        target_compile_definitions(test_WD_hybrid_noWebkit_with_shared_libs PRIVATE QT_NO_QML)
    endif()

    if(NOT WD_BUILD_MONGOOSE)
        target_sources(test_WD_hybrid_noWebkit_with_shared_libs PRIVATE ${CMAKE_SOURCE_DIR}/src/third_party/mongoose/mongoose.c)
    endif()

    install(TARGETS test_WD_hybrid_noWebkit_with_shared_libs
        RUNTIME DESTINATION bin
    )
endif()

# ============================================================================
# Android test targets
# ============================================================================

if(ANDROID)
    # test_android_WD_QML
    add_library(test_android_WD_QML SHARED main.cc)

    set_target_properties(test_android_WD_QML PROPERTIES
        OUTPUT_NAME AndroidWD_QML
    )

    target_link_libraries(test_android_WD_QML
        PRIVATE
            chromium_base
            WebDriver_core
            WebDriver_extension_qt_base
            WebDriver_extension_qt_quick
            test_widgets
    )

    if(QT5)
        target_link_libraries(test_android_WD_QML PRIVATE
            Qt5::Multimedia
            Qt5::MultimediaWidgets
            Qt5::Quick
            Qt5::Qml
        )
    endif()

    if(NOT WD_BUILD_MONGOOSE)
        target_sources(test_android_WD_QML PRIVATE ${CMAKE_SOURCE_DIR}/src/third_party/mongoose/mongoose.c)
    endif()

    # test_android_WD_Widgets
    add_library(test_android_WD_Widgets SHARED main.cc)

    set_target_properties(test_android_WD_Widgets PROPERTIES
        OUTPUT_NAME AndroidWD_Widgets
    )

    target_compile_definitions(test_android_WD_Widgets PRIVATE QT_NO_QML)

    target_link_libraries(test_android_WD_Widgets
        PRIVATE
            chromium_base
            WebDriver_core
            WebDriver_extension_qt_base
            test_widgets
    )

    if(NOT WD_BUILD_MONGOOSE)
        target_sources(test_android_WD_Widgets PRIVATE ${CMAKE_SOURCE_DIR}/src/third_party/mongoose/mongoose.c)
    endif()

    install(TARGETS test_android_WD_QML test_android_WD_Widgets
        LIBRARY DESTINATION lib
    )
endif()

# ============================================================================
# iOS test target
# ============================================================================

if(IOS)
    add_executable(test_ios_WD MACOSX_BUNDLE main.cc)

    set_target_properties(test_ios_WD PROPERTIES
        OUTPUT_NAME WebDriver_ios
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    )

    target_link_libraries(test_ios_WD
        PRIVATE
            chromium_base
            WebDriver_core
            WebDriver_extension_qt_base
            WebDriver_extension_qt_quick
            test_widgets
    )

    if(NOT WD_BUILD_MONGOOSE)
        target_sources(test_ios_WD PRIVATE ${CMAKE_SOURCE_DIR}/src/third_party/mongoose/mongoose.c)
    endif()

    install(TARGETS test_ios_WD
        BUNDLE DESTINATION .
    )
endif()
