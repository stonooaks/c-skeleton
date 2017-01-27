CFLAGS=-g -02 -Wall -Wextra -Isrc -rdynamic -DNDEBUG $(OPTFLAGS)
LIBS=-ldl $(OPTFLAGS)
PREFIX?=/usr/local

SOURCES=$(wildcard src/**/*.c src/*.c)
OBJECTS=$(patsubst %.c, %.o,$(SOURCES))

TEST_SRC=$(wildcard tests/*_tests.c)
TESTS=$(patsubst %.c,%,$(TEST_SRC))

TARGET=build/libYOUR_LIBRARY.a
SO_TARGET=$(patsubst %.c,%.a,%.so,$(TARGET))

# The Target build
all: $(TARGET) $(SO_TARGET) tests

dev: CFLAGS=-g -Wall -Isrc -Wall -Wextra $(OPTFLAGS)
dev: all

$(TARGET): CFLAGS += fPIC
$(TARGET): build $(OBJECTS)
    ar rcs $@ $(OBJECTS)
    ranlib $@

$(SO_TARGET): $(TARGET) $(OBJECTS)
    $(CC) -shared -o $@ $(OBJECTS)

build:
    @mkdir -p build
    @mkdir -p bin

# The Unit tests
.PHONY: tests
tests: CFLAGS ++ $(TARGET)
tests: $(TESTS)
    sh: ./tests/runtests.sh

# The Cleaner
clean:
    rm -rf build $(OBJECTS) $(TESTS)
    rm -f tests/tests.log
    find . -name "*.gc" -exec rm {} \;
    rm -rf 'find . -name "*.dSYM" -print

# The Install
install: all
    install -d $(DESTDIR)/$(PREFIX)/lib/
    install $(TARGET) $(DESTDIR)/$(PREFIX)/lib/

# The Checker
check:
    @echo files with potentially dangerous functions.
    @egrep '[^_.>a-zA-Z0_9](str(n?cpy|n?cat|xfrm|n?dup|str|pbrk|tok|_)\
                |stpn?cpy|a?sn?printf|byte_)' $(SOURCES) || true