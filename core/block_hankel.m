function H = block_hankel(W, K)

[q, T] = size(W);
L = T - K + 1;
if L <= 0
    error('Not enough data for Hankel depth K.');
end

H = zeros(q*K, L);
for i = 1:K
    H((i-1)*q+1:i*q, :) = W(:, i:i+L-1);
end
end
