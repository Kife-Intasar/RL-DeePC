function [Up, Uf, Yp, Yf] = split_deepc_matrix(M, m, p, Tini, N)

ru_p = m*Tini;
ru_f = m*N;
ry_p = p*Tini;

Up = M(1:ru_p,:);
Uf = M(ru_p+1:ru_p+ru_f,:);
Yp = M(ru_p+ru_f+1:ru_p+ru_f+ry_p,:);
Yf = M(ru_p+ru_f+ry_p+1:end,:);
end
