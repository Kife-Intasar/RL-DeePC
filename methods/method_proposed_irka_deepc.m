function out = method_proposed_irka_deepc(plant, data, ref, info, cfg) 


out = run_deepc_soft_subspace_closed_loop( ...
    plant, info.W, info.irka_deepc.V, ref, cfg, cfg.lambda_g, cfg.lambda_sigma, 0, cfg.irka_soft);
out.method = 'proposed_irka_deepc';
out.reduced_order = info.irka_deepc.rank;
out.order_history = info.irka_deepc.rank * ones(1, cfg.Tsim);
out.model_order = info.irka_deepc.model_order;
out.basis_source = 'IRKA-informed fast projector DeePC';
out.is_proposed = true;
out.fast_projector_formulation = true;
out.soft_formulation = false;
out.standard_formulation = false;
out.true_online_reduction = false;
out.latent_dim_full = info.irka_deepc.num_columns;
out.latent_dim_reduced = info.irka_deepc.num_reduced_columns;
out.online_reduction_ratio = info.irka_deepc.num_reduced_columns / max(1, info.irka_deepc.num_columns);
out.reduction_basis = 'IRKA';
out.reduction_matrix_columns = info.irka_deepc.num_reduced_columns;
out.original_matrix_columns = info.irka_deepc.num_columns;
end
