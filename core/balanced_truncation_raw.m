function [Ab, Bb, Cb, Db, hsv, T, Ti] = balanced_truncation_raw(A, B, C, D, r)

Pc = dlyap_raw(A, B*B');
Po = dlyap_raw(A', C'*C);

Sc = sqrtm_psd_raw(Pc);
So = sqrtm_psd_raw(Po);

[U,S,V] = svd(So' * Sc, 'econ');
sig = max(real(diag(S)), 0);
hsv = sqrt(sig);

rr = min([r, numel(hsv)]);
Sinv = diag(1 ./ sqrt(hsv(1:rr) + 1e-12));
T = Sc * V(:,1:rr) * Sinv;
Ti = Sinv * U(:,1:rr)' * So';

Ab = Ti * A * T;
Bb = Ti * B;
Cb = C * T;
Db = D;
end
