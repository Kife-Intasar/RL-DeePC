function out = method_proposed_irka_reduced_deepc(plant, data, ref, info, cfg) 

out = run_deepc_reduced_closed_loop( ...
    plant, info.irka_deepc.M, ref, cfg, cfg.irka_reduced, 0);
out.method = 'proposed_irka_reduced_deepc';
out.latent_dim_full = info.irka_deepc.num_columns;
out.latent_dim_reduced = info.irka_deepc.num_reduced_columns;
out.latent_dim = info.irka_deepc.num_reduced_columns;
out.reduced_order = info.irka_deepc.rank;
out.order_history = info.irka_deepc.rank * ones(1, cfg.Tsim);
out.model_order = info.irka_deepc.model_order;
out.basis_source = 'IRKA-informed reduced DeePC';
out.is_proposed = true;
out.fast_projector_formulation = false;
out.soft_formulation = false;
out.standard_formulation = false;
out.reduced_formulation = true;
out.true_online_reduction = true;
out.online_reduction_ratio = info.irka_deepc.num_reduced_columns / max(1, info.irka_deepc.num_columns);
out.method_family = 'reduced-deepc';
out.reduction_basis = 'IRKA';
out.reduction_matrix_columns = info.irka_deepc.num_reduced_columns;
out.original_matrix_columns = info.irka_deepc.num_columns;
end
