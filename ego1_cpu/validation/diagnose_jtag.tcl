open_hw_manager
connect_hw_server -url localhost:3121
set targets [get_hw_targets]
puts "DIAGNOSTIC_TARGET_COUNT: [llength $targets]"
foreach target $targets {
    puts "DIAGNOSTIC_TARGET: $target"
    foreach property {PARAM.TYPE PARAM.DEVICE PARAM.FREQUENCY DEVICE_COUNT IS_OPENED} {
        if {![catch {get_property $property $target} value]} {
            puts "DIAGNOSTIC_PROPERTY $property: $value"
        }
    }
    if {![catch {list_property_value PARAM.FREQUENCY $target} frequencies]} {
        puts "DIAGNOSTIC_SUPPORTED_FREQUENCIES: $frequencies"
    }
}
disconnect_hw_server
close_hw_manager
