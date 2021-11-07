/*
 *  Dancebots GUI - Create choreographies for Dancebots
 *  https://github.com/philippReist/dancebots_gui
 *
 *  Copyright 2019-2021 - mint & pepper
 *
 *  This program is free software : you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  See the GNU General Public License for more details, available in the
 *  LICENSE file included in the repository.
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtSvg>

#include "src/backend.h"
#include "src/primitive.h"

int main(int argc, char* argv[]) {
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
