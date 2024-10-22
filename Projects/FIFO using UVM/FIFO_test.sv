package FIFO_test_pkg;
    import FIFO_read_sqnc_pkg::*;
    import FIFO_rst_sqnc_pkg::*;
    import FIFO_write_sqnc_pkg::*;
    import FIFO_rw_sqnc_pkg::*;
    import FIFO_env_pkg::*;
    import FIFO_config_pkg::*;
    import FIFO_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_test extends uvm_test;
        `uvm_component_utils(FIFO_test)

        FIFO_env env_inst;
        FIFO_config FIFO_config_test;

        FIFO_rst_sqnc reset_seq;
        FIFO_rw_sqnc  rw_seq;
        FIFO_read_sqnc read_seq;
        FIFO_write_sqnc write_seq;

        function new(string name = "FIFO_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env_inst = FIFO_env::type_id::create("env_inst", this);
            FIFO_config_test = FIFO_config::type_id::create("FIFO_config_test");
           
            reset_seq   = FIFO_rst_sqnc::type_id::create("reset_seq");
            read_seq    = FIFO_read_sqnc::type_id::create("read_seq");
            write_seq   = FIFO_write_sqnc::type_id::create("write_seq");
            rw_seq      = FIFO_rw_sqnc::type_id::create("rw_seq");

            if (!uvm_config_db #(virtual FIFO_if)::get(this, "", "IF_KEY", FIFO_config_test.FIFO_config_vif)) begin
                `uvm_fatal("build_phase", "Test - Could not retrieve virtual interface 'IF_KEY' from config_db")
            end

            uvm_config_db#(FIFO_config)::set(this, "*", "FIFO_IF", FIFO_config_test);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);

            LABEL = FIFO_0;
            `uvm_info("run_phase", "Reset asserted", UVM_LOW);
            reset_seq.start(env_inst.agt.sqr);
            `uvm_info("run_phase", "Reset deasserted", UVM_LOW);

            LABEL = FIFO_1;
            `uvm_info("run_phase", "Stimulus generation started, writing more that reading ", UVM_LOW);
            write_seq.start(env_inst.agt.sqr);
            `uvm_info("run_phase", "Stimulus generation ended", UVM_LOW);    
            
            LABEL = FIFO_2;
            `uvm_info("run_phase", "Stimulus generation started, reading more that writing", UVM_LOW);
            read_seq.start(env_inst.agt.sqr);
            `uvm_info("run_phase", "Stimulus generation ended", UVM_LOW);    
            
            LABEL = FIFO_3;
            `uvm_info("run_phase", "Stimulus generation started, equal reads and writes", UVM_LOW);
            rw_seq.start(env_inst.agt.sqr);
            `uvm_info("run_phase", "Stimulus generation ended", UVM_LOW);    

            phase.drop_objection(this);
        endtask 
    endclass
endpackage