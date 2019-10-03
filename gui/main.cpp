#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "BackEnd.hpp"

int main(int argc, char *argv[])
{

    QCoreApplication::setOrganizationName("MINT&Pepper");

    QGuiApplication app(argc, argv);

    BackEnd backend{&app};

    qmlRegisterType<BackEnd>("io.qt.examples.backend", 1, 0, "BackEnd");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl(QStringLiteral("../../gui/main.qml")));

    return app.exec();
}