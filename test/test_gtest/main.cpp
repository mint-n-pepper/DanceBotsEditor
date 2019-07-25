#include <cstdint>
#include <iostream>

#include <gtest/gtest.h>


namespace {
	class Foo {
	public:
		
		Foo(const int_least64_t init_sum) : sum_(init_sum) {};

		void Add(const Foo& other) {
			sum_ += other.GetSum();
		}

		void Subtract(const Foo& other) {
			sum_ -= other.GetSum();
		}

		void Reset(void) {
			sum_ = 0;
		}

		int_least64_t GetSum(void) const {
			return sum_;
		}
	private:
		int_least64_t sum_;
	};

	// Test Fixture Class that creates different constant Foo objects to use in tests
	class FooTest : public ::testing::Test {
	protected:

		FooTest(void) :
			foo_zero_(0),
			foo_one_(1),
			foo_two_(2) {

		}

		void SetUp(void) override {
			std::cout << "Setting up FooTest" << std::endl;
		}

		void TearDown(void) override {
			std::cout << "Tearing Down FooTest" << std::endl;
		}

		Foo foo_zero_;
		Foo foo_one_;
		Foo foo_two_;
	};

	TEST_F(FooTest, AdditionTest) {
		Foo test_foo{ 1 };

		test_foo.Add(foo_zero_);

		EXPECT_EQ(test_foo.GetSum(), 1);
	}

	TEST_F(FooTest, SubtractionTest) {
		Foo test_foo{ 5 };

		test_foo.Subtract(foo_one_);

		EXPECT_EQ(test_foo.GetSum(), 4);
	}

}// namespace


int main(int argc, char* argv[]) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}