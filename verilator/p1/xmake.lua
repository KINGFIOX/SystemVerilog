add_requires("verilator")
target("Valu")  -- 说明 一件事情，就是我的这个设计模块要与这个 target 同名
    add_rules("verilator.binary")
    set_toolchains("@verilator")
    add_files("src/*.sv")
    add_files("src/*.cpp")
    -- add_values("verilator.flags", "--trace", "--timing")
    add_values("verilator.flags", "--trace")