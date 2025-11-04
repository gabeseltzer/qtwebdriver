/****************************************************************************
**
** QtWebDriver Core Headers Only (NO Qt includes!)
** Must be included AFTER all Qt headers
**
****************************************************************************/

#ifndef WD_CORE_ONLY_H
#define WD_CORE_ONLY_H

// IMPORTANT: Include all your Qt headers BEFORE including this file!

#include <iostream>

// Workaround for time.h conflicts between chromium base and std library
// Chromium base redefines some time functions that conflict with C++ <ctime>
#if defined(__has_include)
#if __has_include(<bits/types/time_t.h>)
#include <bits/types/time_t.h>
#endif
#endif

// WebDriver base headers (chromium base)
#include "base/at_exit.h"
#include "base/command_line.h"

// WebDriver core headers  
#include "webdriver_server.h"
#include "webdriver_view_transitions.h"
#include "versioninfo.h"
#include "webdriver_route_table.h"
#include "webdriver_route_patterns.h"
#include "webdriver_switches.h"
#include "commands/shutdown_command.h"

// Qt Extension headers (forward declare Qt types if needed)
#include "extension_qt/q_view_runner.h"
#include "extension_qt/q_session_lifecycle_actions.h"
#include "extension_qt/widget_view_creator.h"
#include "extension_qt/widget_view_enumerator.h"
#include "extension_qt/widget_view_executor.h"
// Event dispatcher not needed for basic widgets
// #include "extension_qt/wd_event_dispatcher.h"

namespace wd_helpers {

// Minimal wd_setup for Qt 6 Widgets only
inline int setup(int argc, char *argv[])
{
    webdriver::ViewRunner::RegisterCustomRunner<webdriver::QViewRunner>();
    
    webdriver::SessionLifeCycleActions::RegisterCustomLifeCycleActions<webdriver::QSessionLifeCycleActions>();
    
    webdriver::ViewTransitionManager::SetURLTransitionAction(new webdriver::URLTransitionAction_CloseOldView());
    
    // Configure widget views
    webdriver::ViewCreator* widgetCreator = new webdriver::QWidgetViewCreator();
    
    // Register QWidget as creatable view
    widgetCreator->RegisterViewClass<QWidget>("QWidget");
    
    webdriver::ViewFactory::GetInstance()->AddViewCreator(widgetCreator);
    
    webdriver::ViewEnumerator::AddViewEnumeratorImpl(new webdriver::WidgetViewEnumeratorImpl());
    
    webdriver::ViewCmdExecutorFactory::GetInstance()->AddViewCmdExecutorCreator(new webdriver::QWidgetViewCmdExecutorCreator());
    
    // Event dispatcher is added conditionally (VNC or UInput) - not needed for basic widgets
    
    // Parse command line
    CommandLine cmd_line(CommandLine::NO_PROGRAM);
#if defined(OS_WIN)
    cmd_line.ParseFromString(::GetCommandLineW());
#elif defined(OS_POSIX)
    cmd_line.InitFromArgv(argc, argv);
#endif
    
    // Start WebDriver server (singleton)
    webdriver::Server* server = webdriver::Server::GetInstance();
    int result = server->Configure(cmd_line);
    if (result != 0) {
        std::cout << "Error while configuring WD server, exiting..." << std::endl;
        return result;
    }
    
    server->Start();
    
    return 0;
}

} // namespace wd_helpers

#endif // WD_CORE_ONLY_H
