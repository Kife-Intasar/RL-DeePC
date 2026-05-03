function M = compute_prediction_metrics(y_true_flat, y_pred_flat, y_train, solve_times, order)
%COMPUTE_PREDICTION_METRICS Aggregate prediction metrics for SCIS studies.

y_true = y_true_flat(:);
y_pred = y_pred_flat(:);
err = y_true - y_pred;
abs_err = abs(err);

M.rmse = sqrt(mean(err.^2));
M.mae = mean(abs_err);
M.nrmse = M.rmse / max(std(y_true), eps);
M.nrmse_range = M.rmse / max(max(y_true) - min(y_true), eps);
M.fit = 100 * (1 - norm(err,2) / max(norm(y_true - mean(y_train(:)),2), eps));
M.r2 = 1 - sum(err.^2) / max(sum((y_true - mean(y_true)).^2), eps);

solve_ms = 1000 * solve_times(:);
M.mean_solve_ms = mean(solve_ms);
M.median_solve_ms = median(solve_ms);
M.p95_solve_ms = local_prctile(solve_ms, 95);
M.worst_solve_ms = max(solve_ms);
M.solve_std_ms = std(solve_ms);

M.order = order;
M.num_windows = numel(solve_ms);
end

function v = local_prctile(x, p)
if isempty(x)
    v = NaN;
    return;
end
x = sort(x(:));
idx = max(1, min(numel(x), ceil((p/100) * numel(x))));
v = x(idx);
end
