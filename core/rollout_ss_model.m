function Y = rollout_ss_model(model, U, x0)

if nargin < 3 || isempty(x0)
    x0 = zeros(size(model.A,1),1);
end

T = size(U,2);
p = size(model.C,1);
Y = zeros(p, T);
x = x0(:);

for k = 1:T
    uk = U(:,k);
    Y(:,k) = model.C * x + model.D * uk;
    x = model.A * x + model.B * uk;
end
end
