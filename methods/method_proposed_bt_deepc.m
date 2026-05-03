function out = method_proposed_bt_deepc(plant, data, ref, info, cfg) 

out = run_deepc_soft_subspace_closed_loop( ...
    plant, info.W, info.bt_deepc.V, ref, cfg, cfg.lambda_g, cfg.lambda_sigma, 0, cfg.bt_soft);
out.method = 'proposed_bt_deepc';
out.reduced_order = info.bt_deepc.rank;
out.order_history = info.bt_deepc.rank * ones(1, cfg.Tsim);
out.model_order = info.bt_deepc.model_order;
out.basis_source = 'BT-informed fast projector DeePC';
out.is_proposed = true;
out.fast_projector_formulation = true;
out.soft_formulation = false;
out.standard_formulation = false;
out.true_online_reduction = false;
out.latent_dim_full = info.bt_deepc.num_columns;
out.latent_dim_reduced = info.bt_deepc.num_reduced_columns;
out.online_reduction_ratio = info.bt_deepc.num_reduced_columns / max(1, info.bt_deepc.num_columns);
out.reduction_basis = 'BT';
out.reduction_matrix_columns = info.bt_deepc.num_reduced_columns;
out.original_matrix_columns = info.bt_deepc.num_columns;
end
