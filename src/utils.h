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

#ifndef SRC_UTILS_H_
#define SRC_UTILS_H_

#include <vector>

namespace utils {
enum class SearchMethod { Binary = 0, Linear };

/**
 * \brief Find index of first element smaller equal to a given value in a
 * monotonically increasing vector.
 *
 * Given value v, the function returns the index i in vector vect for which
 *
 *   vect[i] <= v < vect[i+i]
 *
 * The function aborts and returns -1 if the vector contains fewer than
 * 2 elements or value is smaller than first element or larger equal the last
 * element.
 *
 * \param[in] value - Value that should be found
 * \param[in] intervals - vector of monotonically increasing intervals
 * \param[out] ind - index i as defined above
 * \param[in] method - search method (binary or linear),
 * default binary (faster)
 * \return Whether the operation was successful (0) or not (-1).
 */
template <class T>
int findInterval(const T value, const std::vector<T>& intervals, size_t* ind,
                 const SearchMethod method = SearchMethod::Binary) {
  // check if intervals contains at least two values:
  if (intervals.size() < 2) {
    return -1;
  }
  // check if value is in valid range of vector:
  if (value < intervals.front() || value >= intervals.back()) {
    return -1;
  }

  // otherwise, find interval
  switch (method) {
    case SearchMethod::Binary: {
      // init index to 0
      *ind = 0;
      // init step size to half vector size
      size_t step = intervals.size() / 2;
      // boolean that determines if the index is increased or not
      bool increase = true;

      // search until a valid interval is found
      while (intervals[*ind] > value || intervals[*ind + 1] <= value) {
        // increase ind
        *ind = increase ? *ind + step : *ind - step;
        // decrease step size
        if (step / 2 != 0) {
          step = step / 2;
        }
        // find next increase direction
        increase = intervals[*ind] < value;
      }
      break;
    }
    case SearchMethod::Linear: {
      *ind = 0;
      while (intervals[*ind] <= value) {
        *ind += 1;
      }
      *ind -= 1;
      break;
    }
  }
  return 0;
}
}  // namespace utils

#endif  // SRC_UTILS_H_
