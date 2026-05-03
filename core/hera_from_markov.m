function [A, B, C, D, hsv, meta] = hera_from_markov(G, s, l, r, cfg)

if numel(G) < s + l + 1
    error('Not enough Markov parameters for HERA.');
end
[p, m] = size(G{1});

row_w = exp(-cfg.hera_row_decay * (0:s-1));
col_w = exp(-cfg.hera_col_decay * (0:l-1));
row_w = row_w / row_w(1);
col_w = col_w / col_w(1);
Wy = kron(diag(row_w), eye(p));
Wu = kron(diag(col_w), eye(m));

H0 = zeros(p*s, m*l);
H1 = zeros(p*s, m*l);
for i = 1:s
    for j = 1:l
        H0((i-1)*p+1:i*p, (j-1)*m+1:j*m) = G{i+j-1};
        H1((i-1)*p+1:i*p, (j-1)*m+1:j*m) = G{i+j};
    end
end

Hw0 = Wy * H0 * Wu;
Hw1 = Wy * H1 * Wu;
[U,S,V] = svd(Hw0, 'econ');
sv = diag(S);
r = min([r, numel(sv), size(U,2), size(V,2)]);
Ur = U(:,1:r);
Sr = S(1:r,1:r);
Vr = V(:,1:r);

Sr_inv_sqrt = diag(1 ./ sqrt(diag(Sr) + 1e-12));
Sr_sqrt = diag(sqrt(diag(Sr) + 1e-12));

A = Sr_inv_sqrt * (Ur' * Hw1 * Vr) * Sr_inv_sqrt;
B = Sr_sqrt * Vr(1:m, :)';
C = Ur(1:p, :) * Sr_sqrt;
D = zeros(p,m);

hsv = diag(Sr);
meta = struct();
meta.row_weights = row_w;
meta.col_weights = col_w;
meta.H0 = H0;
meta.H1 = H1;
meta.Hw0 = Hw0;
meta.Hw1 = Hw1;
end
