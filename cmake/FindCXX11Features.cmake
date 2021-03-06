#
# Module that checks for supported C++11 (former C++0x) features.
#
# Sets the follwing variable:
#
# HAVE_NULLPTR                     True if nullptr is available
# HAVE_ARRAY                       True if header <array> and fill() are available
# HAVE_ATTRIBUTE_ALWAYS_INLINE     True if attribute always inline is supported
# HAS_ATTRIBUTE_UNUSED             True if attribute unused is supported
# HAS_ATTRIBUTE_DEPRECATED         True if attribute deprecated is supported
# HAS_ATTRIBUTE_DEPRECATED_MSG     True if attribute deprecated("msg") is supported
# HAVE_STATIC_ASSERT               True if static_assert is available
# HAVE_VARIADIC_TEMPLATES          True if variadic templates are supprt
# HAVE_VARIADIC_CONSTRUCTOR_SFINAE True if variadic constructor sfinae is supported
# HAVE_RVALUE_REFERENCES           True if rvalue references are supported

# test for C++11 flags
include(TestCXXAcceptsFlag)

# try to use compiler flag -std=c++11
CHECK_CXX_ACCEPTS_FLAG("-std=c++11" CXX_FLAG_CXX11)
if(CXX_FLAG_CXX11)
  set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -std=c++11")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 ")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++11 ")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -std=c++11 ")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++11 ")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -std=c++11 ")
  set(CXX_STD0X_FLAGS "-std=c++11")
else()
  # try to use compiler flag -std=c++0x for older compilers
  CHECK_CXX_ACCEPTS_FLAG("-std=c++0x" CXX_FLAG_CXX0X)
  if(CXX_FLAG_CXX0X)
    set(CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS} -std=c++0x" )
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x ")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++0x ")
    set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -std=c++0x ")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++0x ")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -std=c++0x ")
  set(CXX_STD0X_FLAGS "-std=c++0x")
  endif(CXX_FLAG_CXX0X)
endif(CXX_FLAG_CXX11)

# perform tests
include(CheckCXXSourceCompiles)

# nullptr
CHECK_CXX_SOURCE_COMPILES("
    int main(void)
    {
      char* ch = nullptr;
      return 0;
    }
"  HAVE_NULLPTR
)

# array and fill
CHECK_CXX_SOURCE_COMPILES("
    #include <array>
    
    int main(void)
    {
      std::array<int,2> a;
      a.fill(9);
      return 0;
    }
" HAVE_ARRAY
)

# __attribute__((always_inline))
CHECK_CXX_SOURCE_COMPILES("
   void __attribute__((always_inline)) foo(void) {}
   int main(void)
   {
     foo();
     return 0;
   };
"  HAVE_ATTRIBUTE_ALWAYS_INLINE
)

# __attribute__((unused))
CHECK_CXX_SOURCE_COMPILES("
   int main(void)
   {
     int __attribute__((unused)) foo;
     return 0;
   };
"  HAS_ATTRIBUTE_UNUSED
)

# __attribute__((deprecated))
CHECK_CXX_SOURCE_COMPILES("
#define DEP __attribute__((deprecated))
   class bar
   {
     bar() DEP;
   };
   
   class peng { } DEP;
   
   template <class T>
   class t_bar
   {
     t_bar() DEP;
   };
   
   template <class T>
   class t_peng {
     t_peng() {};
   } DEP;
   
   void foo() DEP;
   
   void foo() {};
   
   int main(void)
   {
     return 0;
   };
"  HAS_ATTRIBUTE_DEPRECATED
)

# __attribute__((deprecated("msg")))
CHECK_CXX_SOURCE_COMPILES("
#define DEP __attribute__((deprecated(\"message\")))
   class bar {
     bar() DEP;
   };
   
   class peng { } DEP;
   
   template <class T>
   class t_bar
   {
     t_bar() DEP;
   };
   
   template <class T>
   class t_peng
   {
     t_peng() {}; 
   } DEP;
   
   void foo() DEP;
   
   void foo() {};
   
   int main(void)
   {
     return 0;
   };
"  HAS_ATTRIBUTE_DEPRECATED_MSG
)

# static assert
CHECK_CXX_SOURCE_COMPILES("
   int main(void)
   {
     static_assert(true,\"MSG\");
     return 0;
   }
"  HAVE_STATIC_ASSERT
)

# variadic template support
CHECK_CXX_SOURCE_COMPILES("
   #include <cassert>

   template<typename... T>
   int addints(T... x);

   int add_ints()
   {
     return 0;
   }

   template<typename T1, typename... T>
   int add_ints(T1 t1, T... t)
   {
     return t1 + add_ints(t...);
   }

   int main(void)
   {
     assert( 5 == add_ints(9,3,-5,-2) );
     return 0;
   }
" HAVE_VARIADIC_TEMPLATES
)

# SFINAE on variadic template constructors within template classes
CHECK_CXX_SOURCE_COMPILES("
  #include <functional>

  template<typename... U>
  struct A
  {
    template<typename... T,
             typename = typename std::enable_if<(sizeof...(T) < 2)>::type
            >
    A(T... t)
    : i(1)
    {}

    template<typename... T,
             typename = typename std::enable_if<(sizeof...(T) >= 2)>::type,
             typename = void
            >
    A(T... t)
    : i(-1)
    {}

    A()
    : i(1)
    {}

    int i;
  };

  int main(void)
  {
    return (A<int>().i + A<int>(2).i + A<int>(\"foo\",3.4).i + A<int>(8,'a',A<int>()).i == 0 ? 0 : 1);
  }
" HAVE_VARIADIC_CONSTRUCTOR_SFINAE
)

# rvalue references
CHECK_CXX_SOURCE_COMPILES("
  #include <cassert>
  #include <utility>
  int foo(int&& x) { return 1; }
  int foo(const int& x) { return -1; }

  template<typename T>
  int forward(T&& x)
  {
    return foo(std::forward<T>(x));
  }

  int main(void)
  {
    int i = 0;
    assert( forward(i) + forward(int(2)) == 0);
    return 0;
  }
" HAVE_RVALUE_REFERENCES
)
include(CheckIncludeFile)
include(CheckIncludeFileCXX)
# Search for some tr1 headers
foreach(_HEADER tuple tr1/tuple type_traits tr1/type_traits)
  string(REPLACE "/" "_" _HEADER_VAR ${_HEADER})
  string(TOUPPER ${_HEADER_VAR} _HEADER_VAR )
  check_include_file_cxx(${_HEADER} "HAVE_${_HEADER_VAR}")
endforeach(_HEADER tuple tr1/tuple tr1/type_traits)


