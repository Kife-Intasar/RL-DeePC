function [Up, Uf, Yp, Yf] = build_deepc_blocks(U, Y, Tini, N)
%BUILD_DEEPC_BLOCKS Build past/future Hankel blocks.

Hu = block_hankel(U, Tini + N);
Hy = block_hankel(Y, Tini + N);

m = size(U,1);
p = size(Y,1);

Up = Hu(1:m*Tini,:);
Uf = Hu(m*Tini+1:end,:);
Yp = Hy(1:p*Tini,:);
Yf = Hy(p*Tini+1:end,:);
end
