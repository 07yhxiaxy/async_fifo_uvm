// Inside fifo_seq_item.sv
constraint c_dist { dist_val inside { [0:10]:=80, [11:100]:=20 }; } // Mostly short delays