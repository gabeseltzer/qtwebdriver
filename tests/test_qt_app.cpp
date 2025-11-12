/****************************************************************************
**
** QtWebDriver Test Application with UI Buttons
**
****************************************************************************/

// Include Qt headers first
#include <QtWidgets/QApplication>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QWidget>
#include <QtWidgets/QGroupBox>
#include <QFont>

// NOW include QtWebDriver headers (after all Qt headers!)
#include "wd_core_only.h"

class TestWindow : public QMainWindow {
    Q_OBJECT

public:
    TestWindow(QWidget *parent = nullptr) : QMainWindow(parent) {
        setWindowTitle("QtWebDriver Test Application");
        setMinimumSize(600, 500);

        // Central widget
        QWidget *centralWidget = new QWidget(this);
        setCentralWidget(centralWidget);

        QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);
        mainLayout->setSpacing(20);
        mainLayout->setContentsMargins(20, 20, 20, 20);

        // Title
        QLabel *titleLabel = new QLabel("QtWebDriver Test Application", this);
        QFont titleFont = titleLabel->font();
        titleFont.setPointSize(18);
        titleFont.setBold(true);
        titleLabel->setFont(titleFont);
        titleLabel->setObjectName("title-label");
        mainLayout->addWidget(titleLabel);

        // Simple Buttons Group
        QGroupBox *simpleButtonsGroup = new QGroupBox("Simple Buttons", this);
        QHBoxLayout *simpleButtonsLayout = new QHBoxLayout(simpleButtonsGroup);
        
        helloButton = new QPushButton("Say Hello", this);
        helloButton->setObjectName("btn-hello");
        connect(helloButton, &QPushButton::clicked, this, &TestWindow::onHelloClicked);
        simpleButtonsLayout->addWidget(helloButton);

        goodbyeButton = new QPushButton("Say Goodbye", this);
        goodbyeButton->setObjectName("btn-goodbye");
        connect(goodbyeButton, &QPushButton::clicked, this, &TestWindow::onGoodbyeClicked);
        simpleButtonsLayout->addWidget(goodbyeButton);

        clearButton = new QPushButton("Clear Message", this);
        clearButton->setObjectName("btn-clear");
        connect(clearButton, &QPushButton::clicked, this, &TestWindow::onClearClicked);
        simpleButtonsLayout->addWidget(clearButton);

        mainLayout->addWidget(simpleButtonsGroup);

        // Counter Group
        QGroupBox *counterGroup = new QGroupBox("Counter", this);
        QVBoxLayout *counterLayout = new QVBoxLayout(counterGroup);

        counterLabel = new QLabel("0", this);
        counterLabel->setObjectName("counter");
        QFont counterFont = counterLabel->font();
        counterFont.setPointSize(24);
        counterFont.setBold(true);
        counterLabel->setFont(counterFont);
        counterLabel->setAlignment(Qt::AlignCenter);
        counterLayout->addWidget(counterLabel);

        QHBoxLayout *counterButtonsLayout = new QHBoxLayout();
        
        incrementButton = new QPushButton("Increment (+1)", this);
        incrementButton->setObjectName("btn-increment");
        connect(incrementButton, &QPushButton::clicked, this, &TestWindow::onIncrementClicked);
        counterButtonsLayout->addWidget(incrementButton);

        decrementButton = new QPushButton("Decrement (-1)", this);
        decrementButton->setObjectName("btn-decrement");
        connect(decrementButton, &QPushButton::clicked, this, &TestWindow::onDecrementClicked);
        counterButtonsLayout->addWidget(decrementButton);

        resetButton = new QPushButton("Reset Counter", this);
        resetButton->setObjectName("btn-reset");
        connect(resetButton, &QPushButton::clicked, this, &TestWindow::onResetClicked);
        counterButtonsLayout->addWidget(resetButton);

        counterLayout->addLayout(counterButtonsLayout);
        mainLayout->addWidget(counterGroup);

        // Text Input Group
        QGroupBox *inputGroup = new QGroupBox("Text Input", this);
        QVBoxLayout *inputLayout = new QVBoxLayout(inputGroup);

        textInput = new QLineEdit(this);
        textInput->setObjectName("text-input");
        textInput->setPlaceholderText("Enter some text here...");
        inputLayout->addWidget(textInput);

        submitButton = new QPushButton("Submit Text", this);
        submitButton->setObjectName("btn-submit");
        connect(submitButton, &QPushButton::clicked, this, &TestWindow::onSubmitClicked);
        inputLayout->addWidget(submitButton);

        mainLayout->addWidget(inputGroup);

        // Result Display
        QGroupBox *resultGroup = new QGroupBox("Result", this);
        QVBoxLayout *resultLayout = new QVBoxLayout(resultGroup);

        resultLabel = new QLabel("No actions yet", this);
        resultLabel->setObjectName("result-text");
        resultLabel->setWordWrap(true);
        resultLabel->setMinimumHeight(60);
        resultLabel->setStyleSheet("QLabel { padding: 10px; background-color: #f0f0f0; border: 1px solid #ccc; border-radius: 5px; }");
        resultLayout->addWidget(resultLabel);

        mainLayout->addWidget(resultGroup);

        // Add stretch to push everything to the top
        mainLayout->addStretch();

        counter = 0;
    }

private slots:
    void onHelloClicked() {
        resultLabel->setText("Hello from QtWebDriver!");
    }

    void onGoodbyeClicked() {
        resultLabel->setText("Goodbye!");
    }

    void onClearClicked() {
        resultLabel->setText("Message cleared");
    }

    void onIncrementClicked() {
        counter++;
        counterLabel->setText(QString::number(counter));
        resultLabel->setText(QString("Counter incremented to %1").arg(counter));
    }

    void onDecrementClicked() {
        counter--;
        counterLabel->setText(QString::number(counter));
        resultLabel->setText(QString("Counter decremented to %1").arg(counter));
    }

    void onResetClicked() {
        counter = 0;
        counterLabel->setText("0");
        resultLabel->setText("Counter reset to 0");
    }

    void onSubmitClicked() {
        QString text = textInput->text();
        if (!text.isEmpty()) {
            resultLabel->setText(QString("You submitted: %1").arg(text));
        } else {
            resultLabel->setText("No text entered!");
        }
    }

private:
    QPushButton *helloButton;
    QPushButton *goodbyeButton;
    QPushButton *clearButton;
    QPushButton *incrementButton;
    QPushButton *decrementButton;
    QPushButton *resetButton;
    QPushButton *submitButton;
    QLabel *counterLabel;
    QLabel *resultLabel;
    QLineEdit *textInput;
    int counter;
};

int main(int argc, char *argv[]) {
    // Initialize QtWebDriver before creating QApplication
    base::AtExitManager exit;
    
    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(false);
    
    // Set application name for QtWebDriver to find
    app.setApplicationName("QtWebDriverTestApp");
    app.setOrganizationName("QtWebDriver");

    // Initialize QtWebDriver server (embedded mode)
    // This starts the WebDriver server in the same process
    wd_helpers::setup(argc, argv);

    TestWindow window;
    window.setWindowTitle("QtWebDriver Test Application");
    window.show();

    return app.exec();
}

#include "test_qt_app.moc"
