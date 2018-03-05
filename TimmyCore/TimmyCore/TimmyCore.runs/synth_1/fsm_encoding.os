
 add_fsm_encoding \
       {ram2ddrxadc.cState} \
       { }  \
       {{000 000} {001 001} {010 010} {011 011} {100 100} }

 add_fsm_encoding \
       {ram_controller_timmy.current_state} \
       { }  \
       {{000 000} {001 001} {010 010} {011 100} {100 011} }

 add_fsm_encoding \
       {MMU_timmy_stub_V2.curr_state} \
       { }  \
       {{00 00} {01 01} {10 10} {11 11} }
