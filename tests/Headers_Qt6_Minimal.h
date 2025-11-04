/****************************************************************************
**
** Minimal QtWebDriver Setup for Qt 6 Widgets Only
** Based on src/Test/Headers.h but simplified for Qt 6
**
****************************************************************************/

#ifndef WD_SETUP_MINIMAL_H
#define WD_SETUP_MINIMAL_H

#include <QtCore/QObject>
#include <QtWidgets/QApplication>

#include <iostream>

#include "base/at_exit.h"
#include "webdriver_server.h"
#include "webdriver_view_transitions.h"
#include "versioninfo.h"
#include "webdriver_route_table.h"
#include "commands/shutdown_command.h"
#include "webdriver_route_patterns.h"

// Qt Extension Headers (Widgets only)
#include "extension_qt/q_view_runner.h"
#include "extension_qt/q_session_lifecycle_actions.h"
#include "extension_qt/widget_view_creator.h"
#include "extension_qt/widget_view_enumerator.h"
#include "extension_qt/widget_view_executor.h"
#include "extension_qt/wd_event_dispatcher.h"

#include "webdriver_switches.h"

// Minimal wd_setup for Qt 6 Widgets only
inline int wd_setup(int argc, char *argv[])
{
    webdriver::ViewRunner::RegisterCustomRunner<webdriver::QViewRunner>();
    
    webdriver::SessionLifeCycleActions::RegisterCustomLifeCycleActions<webdriver::QSessionLifeCycleActions>();
    
    webdriver::ViewTransitionManager::SetURLTransitionAction(new webdriver::URLTransitionAction_CloseOldView());
    
    // Configure widget views
    webdriver::ViewCreator* widgetCreator = new webdriver::QWidgetViewCreator();
    
    // Register QWidget as creatable view
    widgetCreator->RegisterViewClass<QWidget>("QWidget");
    
    webdriver::ViewFactory::GetInstance()->AddViewCreator(widgetCreator);
    
    webdriver::ViewEnumerator::AddViewEnumeratorImpl(new webdriver::QWidgetViewEnumeratorImpl());
    
    webdriver::ViewCmdExecutorFactory::GetInstance()->AddViewCmdExecutorCreator(new webdriver::QWidgetViewCmdExecutorCreator());
    
    // Set up event dispatcher
    webdriver::WDEventDispatcher::getInstance()->setQtEventDispatcher(true);
    
    // Parse command line
    CommandLine cmd_line(CommandLine::NO_PROGRAM);
#if defined(OS_WIN)
    cmd_line.ParseFromString(::GetCommandLineW());
#elif defined(OS_POSIX)
    cmd_line.InitFromArgv(argc, argv);
#endif
    
    // Start WebDriver server
    webdriver::Server* server = new webdriver::Server(cmd_line);
    int result = server->Configure();
    if (result != 0) {
        std::cerr << "Failed to configure WebDriver server" << std::endl;
        return result;
    }
    
    server->Start();
    
    return 0;
}

#endif // WD_SETUP_MINIMAL_H
