function out = method_proposed_bt_reduced_deepc(plant, data, ref, info, cfg)

out = run_deepc_reduced_closed_loop( ...
    plant, info.bt_deepc.M, ref, cfg, cfg.bt_reduced, 0);
out.method = 'proposed_bt_reduced_deepc';
out.latent_dim_full = info.bt_deepc.num_columns;
out.latent_dim_reduced = info.bt_deepc.num_reduced_columns;
out.latent_dim = info.bt_deepc.num_reduced_columns;
out.reduced_order = info.bt_deepc.rank;
out.order_history = info.bt_deepc.rank * ones(1, cfg.Tsim);
out.model_order = info.bt_deepc.model_order;
out.basis_source = 'BT-informed reduced DeePC';
out.is_proposed = true;
out.fast_projector_formulation = false;
out.soft_formulation = false;
out.standard_formulation = false;
out.reduced_formulation = true;
out.true_online_reduction = true;
out.online_reduction_ratio = info.bt_deepc.num_reduced_columns / max(1, info.bt_deepc.num_columns);
out.method_family = 'reduced-deepc';
out.reduction_basis = 'BT';
out.reduction_matrix_columns = info.bt_deepc.num_reduced_columns;
out.original_matrix_columns = info.bt_deepc.num_columns;
end
