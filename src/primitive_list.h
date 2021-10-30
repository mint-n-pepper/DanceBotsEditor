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

#ifndef SRC_PRIMITIVE_LIST_H_
#define SRC_PRIMITIVE_LIST_H_

#include <QAbstractListModel>

/** \class PrimitiveList
 * \brief Data model to store motor and led primitives in. See documentation of
 * QAbstractListModel for more information about overridden functions.
 */
class PrimitiveList : public QAbstractListModel {
  Q_OBJECT;

  Q_PROPERTY(QObject* parent READ parent WRITE setParent);

 public:
  explicit PrimitiveList(QObject* parent);

  /**
   * \brief Get total number of data items in model
   */
  int rowCount(const QModelIndex& parent = QModelIndex()) const override;

  /**
   * \brief Get data at given index and role. Primitive data is stored at
   * role Qt::UserRole + 1
   */
  QVariant data(const QModelIndex& index, int role) const override;

  /**
   * \brief Provides data item flags
   */
  Qt::ItemFlags flags(const QModelIndex& index) const override;

  /**
   * \brief Set data of given index.
   */
  bool setData(const QModelIndex& index, const QVariant& value,
               int role = Qt::EditRole) override;

  /**
   * \brief Get reference to data in model
   */
  const QList<QObject*>& getData(void);

  // NOLINTNEXTLINE
 public slots:
  /**
   * \brief Add item to model. The model will assume ownership of the object.
   *
   * \param[in] o - pointer to object to add
   */
  void add(QObject* o);

  /**
   * \brief Remove item from model
   *
   * \param[in] o - object pointer to remove
   */
  void remove(QObject* o);

  /**
   * \brief Clear model and delete all data
   */
  void clear(void);

  /**
   * \brief Print beat locations and durations of primitives contained in model.
   */
  void printPrimitives(void) const;

  /**
   * \brief Calls dataChanged singal with given index.
   */
  void callDataChanged(const int index);

 protected:
  /**
   * \brief Defines role names, i.e. maps role numbers to strings to use in qml.
   */
  QHash<int, QByteArray> roleNames() const override;

 private:
  QList<QObject*> mData;
};

#endif  // SRC_PRIMITIVE_LIST_H_
