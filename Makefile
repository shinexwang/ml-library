# A sample Makefile for building Google Test and using it in user
# tests.  Please tweak it to suit your environment and project.  You
# may want to move it to your project's root directory.
#
# SYNOPSIS:
#
#   make [all]  - makes everything.
#   make TARGET - makes the given target.
#   make clean  - removes all files generated by make.

# Please tweak the following variable definitions as needed by your
# project, except GTEST_HEADERS, which you can use in your own targets
# but shouldn't modify.

# Flags passed to the preprocessor.

# the compiler doesn't generate warnings in Google Test headers.
PROGRAM_INCLUDE_DIRS := lib \
                        /usr/local/include \
                        /usr/local/lib \
                        $(GTEST_DIR)/include

CPPFLAGS += $(foreach includedir,$(PROGRAM_INCLUDE_DIRS),-isystem $(includedir))

# Flags passed to the C++ compiler.
CXXFLAGS += -g -Wall -Wextra -pthread -std=c++14

# All tests produced by this Makefile.  Remember to add new tests you
# created to the list.
TESTS = utils_test linear-model_test naive-bayes_test

EXECUTABLE = sample_program

# All Google Test headers.  Usually you shouldn't change this
# definition.
GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h

# House-keeping build targets.

all : $(EXECUTABLE) $(TESTS)

clean :
	rm -f $(TESTS) gtest.a gtest_main.a *.o
	rm -rf $(EXECUTABLE) $(EXECUTABLE).dSYM *.gch

# Builds gtest.a and gtest_main.a.

# Usually you shouldn't tweak such internal variables, indicated by a
# trailing _.
GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)

# For simplicity and to avoid depending on Google Test's
# implementation details, the dependencies specified below are
# conservative and not optimized.  This is fine as Google Test
# compiles fast and for ordinary users its source rarely changes.
gtest-all.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest-all.cc

gtest_main.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest_main.cc

gtest.a : gtest-all.o
	$(AR) $(ARFLAGS) $@ $^

gtest_main.a : gtest-all.o gtest_main.o
	$(AR) $(ARFLAGS) $@ $^

# Builds a sample test.  A test should link with either gtest.a or
# gtest_main.a, depending on whether it defines its own main()
# function.

utils.o : utils.cc utils.h
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c utils.cc

utils_test.o : utils_test.cc utils.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c utils_test.cc

utils_test : utils_test.o gtest_main.a utils.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@

linear-model.o : linear-model.cc linear-model.h
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c linear-model.cc

linear-model_test.o : linear-model_test.cc linear-model.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c linear-model_test.cc

linear-model_test : linear-model_test.o gtest_main.a linear-model.o utils.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@

naive-bayes.o : naive-bayes.cc naive-bayes.h
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c naive-bayes.cc

naive-bayes_test.o : naive-bayes_test.cc naive-bayes.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c naive-bayes_test.cc

naive-bayes_test : naive-bayes_test.o gtest_main.a naive-bayes.o utils.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@

main.o : main.cc
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c main.cc

$(EXECUTABLE) : main.o linear-model.o utils.o
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@
