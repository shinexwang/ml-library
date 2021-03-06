#include <iostream>
#include <vector>

#include "linear-model.h"

int main() {
  ml::Matrix x(3, 2);
  ml::Vector y(3);
  x << 1, 1, 1, 2, 1, 3;
  y << 1, 2, 3;

  auto lr = ml::LinearRegression(0.1);
  lr.fit(x, y);

  return 0;
}
