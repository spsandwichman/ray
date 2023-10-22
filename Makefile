all: test

SRC_DIR = ./src
LOCATION = ./build/rayman
BUILD_FLAGS = 

ifeq ($(OS),Windows_NT)
	MARS_LOCATION = ./build/rayman.exe
endif


clean:
	@rm -rf ./build

build: clean
	@mkdir build
	@odin build $(SRC_DIR) -o:speed $(BUILD_FLAGS) -out:$(MARS_LOCATION)

test: build
	@$(MARS_LOCATION)