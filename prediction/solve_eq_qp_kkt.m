function x = solve_eq_qp_kkt(H, f, Aeq, beq, reg)


if nargin < 5 || isempty(reg)
    reg = 1e-6;
end

n = size(H,1);
H = 0.5*(H + H');

if ~isempty(Aeq)
    row_scale = max(abs(Aeq), [], 2);
    row_scale(row_scale < eps) = 1;
    Aeq_s = Aeq ./ row_scale;
    beq_s = beq ./ row_scale;
    try
        [~, R, E] = qr(Aeq_s', 'vector');
        use_vector_perm = true;
    catch
        [~, R, P] = qr(Aeq_s');
        use_vector_perm = false;
    end

    d = abs(diag(R));
    if isempty(d)
        rA = 0;
    else
        tol = max(size(Aeq_s)) * eps(max(d));
        rA = sum(d > tol);
    end

    if rA > 0
        if use_vector_perm
            keep = sort(E(1:min(rA, numel(E))));
        else
            % Convert permutation matrix to permutation vector
            [~, perm] = max(P, [], 1);
            keep = sort(perm(1:min(rA, numel(perm))));
        end
        Aeq_s = Aeq_s(keep,:);
        beq_s = beq_s(keep);
    else
        Aeq_s = zeros(0,n);
        beq_s = zeros(0,1);
    end
else
    Aeq_s = zeros(0,n);
    beq_s = zeros(0,1);
end

if isempty(Aeq_s)
    x = -(H + reg*eye(n)) \ f;
    return;
end

me = size(Aeq_s,1);
base_reg = max(reg, 1e-10 * max(trace(H),1) / max(n,1));
rhs = [-f; beq_s];

for k = 0:6
    regk = base_reg * (10^k);
    K = [H + regk*eye(n), Aeq_s'; Aeq_s, zeros(me,me)];
    rc = rcond(K);
    if isfinite(rc) && rc > 1e-12
        sol = K \ rhs;
        x = sol(1:n);
        return;
    end
end

sol = pinv(K) * rhs;
x = sol(1:n);
end
