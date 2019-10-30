#ifndef UTILS_H_
#define UTILS_H_

namespace utils {
  enum class SearchMethod {
    eBinary = 0,
    eLinear
  };

  /**
  \brief Find index of first element smaller equal to a given value in a
  monotonically increasing vector.

  Given value v, the function returns the index i in vector vect for which

    vect[i] <= v < vect[i+i]

  The function aborts and returns -1 if the vector contains fewer than 2 elements
  or value is smaller than first element or larger equal the last element.

  \param[in] Value
  \param[in] Vector, monotonically increasing
  \param[out] Index i
  \param[in] Method in [binary search, linear], default binary (faster)
  \return Whether the operation was successful (0) or not (-1).
  */
  template <class T>
  int findInterval(const T value,
                   const std::vector<T>& intervals,
                   size_t& ind,
                   const SearchMethod method = SearchMethod::eBinary) {
    // check if intervals contains at least two values:
    if(intervals.size() < 2) {
      return -1;
    }
    // check if value is in valid range of vector:
    if(value < intervals.front() ||
       value >= intervals.back()) {
      return -1;
    }

    // otherwise, find interval
    switch(method) {
    case SearchMethod::eBinary: {
      // init index to 0
      ind = 0;
      // init step size to half vector size
      size_t step = intervals.size() / 2;
      // boolean that determines if the index is increased or not
      bool increase = true;

      // search until a valid interval is found
      while(intervals[ind] > value || intervals[ind + 1] <= value) {
        // increase ind
        ind = increase ? ind + step : ind - step;
        // decrease step size
        if(step / 2 != 0) {
          step = step / 2;
        }
        // find next increase direction
        increase = intervals[ind] < value;
      }
      break;
    }
    case SearchMethod::eLinear: {
      ind = 0;
      while(intervals[ind] <= value) {
        ++ind;
      }
      ind = ind - 1;
      break;
    }

    }
    return 0;
  }

} // namespace utils

#endif // UTILS_H_
