function model = arx_identify(U, Y, na, nb, reg)


[p,T] = size(Y);
m = size(U,1);
lag = max(na, nb);

Phi = [];
Tgt = [];
for k = lag+1:T
    phi = [];
    for i = 1:na
        phi = [phi; Y(:,k-i)];
    end
    for j = 1:nb
        phi = [phi; U(:,k-j)];
    end
    Phi = [Phi, phi];
    Tgt = [Tgt, Y(:,k)];
end

if isempty(Phi)
    Theta = zeros(p, na*p + nb*m);
else
    Theta = Tgt * Phi' / (Phi*Phi' + reg*eye(size(Phi,1)));
end

Acell = cell(max(na,0),1);
Bcell = cell(max(nb,0),1);
idx = 1;
for i = 1:na
    Acell{i} = Theta(:, idx:idx+p-1); idx = idx + p;
end
for j = 1:nb
    Bcell{j} = Theta(:, idx:idx+m-1); idx = idx + m;
end

model.na = na;
model.nb = nb;
model.A = Acell;
model.B = Bcell;
model.p = p;
model.m = m;
model.lag = lag;
end
