#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtSvg>

#include "BackEnd.h"
#include "Primitive.h"

int main(int argc, char *argv[])
{

    QCoreApplication::setOrganizationName("MINT&Pepper");

    QGuiApplication app(argc, argv);

    BackEnd backend{&app};

    qmlRegisterType<MotorPrimitive>("dancebots.backend", 1, 0, "MotorPrimitive");
    qmlRegisterType<LEDPrimitive>("dancebots.backend", 1, 0, "LEDPrimitive");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}