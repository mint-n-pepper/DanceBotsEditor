#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "BackEnd.h"
#include "Primitive.h"

int main(int argc, char *argv[])
{

    QCoreApplication::setOrganizationName("MINT&Pepper");

    QGuiApplication app(argc, argv);

    BackEnd backend{&app};

    MotorPrimitive* mpriv1 = new MotorPrimitive{};
    MotorPrimitive* mpriv2 = new MotorPrimitive{};

    mpriv1->mPositionBeat = 1;
    mpriv1->mLengthBeat = 4;
    mpriv2->mPositionBeat = 2;
    mpriv2->mLengthBeat = 5;

    backend.motorPrimitives()->add(mpriv1);
    backend.motorPrimitives()->add(mpriv2);

    qmlRegisterType<MotorPrimitive>("dancebots.backend", 1, 0, "MotorPrimitive");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("backend", &backend);
    engine.load(QUrl(QStringLiteral("../../gui/main.qml")));

    return app.exec();
}