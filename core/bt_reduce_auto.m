function [Ab, Bb, Cb, Db, hsv, r, bt_bound] = bt_reduce_auto(A, B, C, D, energy)

[~, ~, ~, ~, hsv_full] = balanced_truncation_raw(A, B, C, D, size(A,1));
r = choose_energy_rank(hsv_full, energy);
[Ab, Bb, Cb, Db, hsv] = balanced_truncation_raw(A, B, C, D, r);
if r < numel(hsv_full)
    bt_bound = 2*sum(hsv_full(r+1:end));
else
    bt_bound = 0;
end
end
