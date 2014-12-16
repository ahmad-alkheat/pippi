require "test_helper"

class MethodSequenceCheckerTest < MiniTest::Test

  class TestCheck < Pippi::Checks::Check
  end

  def setup
    @clz_to_be_checked = Class.new do
      def select(&blk) ; [] ; end
      def size ; 0 ; end
    end
  end

  def test_decorate_should_add_accessor_to_decorated_class
    check = TestCheck.new(nil)
    m = MethodSequenceChecker.new(check, @clz_to_be_checked, "select", "size", MethodSequenceChecker::ARITY_TYPE_BLOCK_ARG, MethodSequenceChecker::ARITY_TYPE_NONE, false)
    m.decorate
    assert @clz_to_be_checked._pippi_check_testcheck.kind_of?(TestCheck)
  end

  def test_decorate_should_add_a_module_that_decorates_the_first_method
    check = TestCheck.new(nil)
    m = MethodSequenceChecker.new(check, @clz_to_be_checked, "select", "size", MethodSequenceChecker::ARITY_TYPE_BLOCK_ARG, MethodSequenceChecker::ARITY_TYPE_NONE, false)
    assert_equal @clz_to_be_checked.ancestors[0], @clz_to_be_checked
    m.decorate
    assert @clz_to_be_checked.ancestors[0] != @clz_to_be_checked
  end

  def test_accept_a_module_in_place_of_the_second_arity_type
    mymodule = Module.new do
      def size
        raise "boom"
      end
    end
    check = TestCheck.new(nil)
    m = MethodSequenceChecker.new(check, @clz_to_be_checked, "select", "size", MethodSequenceChecker::ARITY_TYPE_BLOCK_ARG, mymodule, false)
    m.decorate
    assert_equal("boom", assert_raises(RuntimeError) do
      @clz_to_be_checked.new.select {|x| }.size
    end.message)
  end

end
