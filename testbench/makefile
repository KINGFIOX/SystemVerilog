# 定义编译器和选项
IVERILOG = iverilog
VVP = vvp
FLAGS = -g2012

# 定义源文件和目标
SRCS = $(wildcard *.sv)
TARGET = simv

# 默认目标
all: $(TARGET)

# 编译规则
$(TARGET): $(SRCS)
	$(IVERILOG) $(FLAGS) -I$(UVM_HOME)  -o $@ $^

# 运行仿真
run: $(TARGET)
	$(VVP) $<

# 清理工程
clean:
	rm -f $(TARGET) *.vcd

.PHONY: all run clean
