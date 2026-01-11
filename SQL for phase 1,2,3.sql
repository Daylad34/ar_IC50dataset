
-- Metadata of compounds in Phase 1, 2, or 3 tested against the androgen receptor
SELECT 
    md.chembl_id AS molecule_id,
    md.pref_name AS molecule_name,
    md.max_phase, -- Added this column so you can see which phase each compound is in
    cs.canonical_smiles,
    act.standard_type,
    act.standard_value,
    act.standard_units,
    act.pchembl_value,
    ass.description AS assay_details,
    ass.assay_organism,
    td.pref_name AS target_name,
    td.organism AS target_organism,
    td.target_type
FROM 
    target_dictionary td
JOIN 
    assays ass ON td.tid = ass.tid
JOIN 
    activities act ON ass.assay_id = act.assay_id
JOIN 
    molecule_dictionary md ON act.molregno = md.molregno
JOIN
    compound_structures cs ON md.molregno = cs.molregno
WHERE 
    -- Target filters: Androgen Receptor (Homo sapiens)
    td.chembl_id = 'CHEMBL1871'
    AND td.organism = 'Homo sapiens'
    AND td.target_type = 'SINGLE PROTEIN'
    
    -- Assay and Activity filters
    AND ass.assay_organism = 'Homo sapiens'
    AND act.standard_type = 'IC50'
    
    
    -- Filter for Clinical Phases 1, 2, and 3
    AND md.max_phase IN (1,2,3)
ORDER BY 
    md.max_phase DESC, -- Groups by phase first
    act.pchembl_value DESC;


	--Filtered to contain action_type of all compounds tested against AR in preclinical
SELECT 
    md.chembl_id AS molecule_id,
    md.pref_name AS molecule_name,
    cs.canonical_smiles,
    act.activity_id,             -- Unique ID for each specific experiment
    act.standard_type,
    act.standard_value,
    act.standard_units,
    act.pchembl_value,
    -- Labeling the Action Type from the Assay Description
    CASE 
        WHEN ass.description ILIKE '%ANTAGONIST%' THEN 'ANTAGONIST'
        WHEN ass.description ILIKE '%AGONIST%' AND ass.description NOT ILIKE '%ANTAGONIST%' THEN 'AGONIST'
        WHEN ass.description ILIKE '%INHIBITOR%' THEN 'INHIBITOR'
        WHEN ass.description ILIKE '%BINDING%' THEN 'BINDING AGENT'
        WHEN ass.description ILIKE '%DEGRADER%' OR ass.description ILIKE '%PROTAC%' THEN 'DEGRADER'
        ELSE 'OTHER/MODULATOR'
    END AS action_type,
    ass.description AS assay_details,
    ass.assay_id,                -- Helps identify the source experiment
    td.pref_name AS target_name
FROM 
    target_dictionary td
JOIN 
    assays ass ON td.tid = ass.tid
JOIN 
    activities act ON ass.assay_id = act.assay_id
JOIN 
    molecule_dictionary md ON act.molregno = md.molregno
JOIN 
    compound_structures cs ON md.molregno = cs.molregno
WHERE 
    td.chembl_id = 'CHEMBL1871'
    AND td.target_type = 'SINGLE PROTEIN'
    AND act.standard_type = 'IC50'
    -- Filter for Clinical Phases 1, 2, and 3
    AND md.max_phase IN (1,2,3)
ORDER BY 
    md.chembl_id,                -- Grouping by molecule to see multiple IC50s together
    act.standard_value ASC;      -- Ordering from most potent to least potent


	--Filtered to include only single protein format
	SELECT 
    md.chembl_id AS molecule_id,
    md.pref_name AS molecule_name,
    cs.canonical_smiles,
    act.activity_id,
    act.standard_type,
    act.standard_value,
    act.standard_units,
    act.pchembl_value,
    -- Labeling the Action Type from the Assay Description
    CASE 
        WHEN ass.description ILIKE '%ANTAGONIST%' THEN 'ANTAGONIST'
        WHEN ass.description ILIKE '%AGONIST%' AND ass.description NOT ILIKE '%ANTAGONIST%' THEN 'AGONIST'
        WHEN ass.description ILIKE '%INHIBITOR%' THEN 'INHIBITOR'
        WHEN ass.description ILIKE '%BINDING%' THEN 'BINDING AGENT'
        WHEN ass.description ILIKE '%DEGRADER%' OR ass.description ILIKE '%PROTAC%' THEN 'DEGRADER'
        ELSE 'OTHER/MODULATOR'
    END AS action_type,
    bao.label AS bao_format_label,
    ass.description AS assay_details,
    ass.assay_id,
    td.pref_name AS target_name
FROM 
    target_dictionary td
JOIN 
    assays ass ON td.tid = ass.tid
JOIN 
    activities act ON ass.assay_id = act.assay_id
JOIN 
    molecule_dictionary md ON act.molregno = md.molregno
JOIN 
    compound_structures cs ON md.molregno = cs.molregno
JOIN 
    bioassay_ontology bao ON ass.bao_format = bao.bao_id
WHERE 
    td.chembl_id = 'CHEMBL1871'
    AND td.target_type = 'SINGLE PROTEIN'
    AND act.standard_type = 'IC50'
    AND act.standard_value IS NOT NULL
    AND md.max_phase IN (1,2,3)
    -- Filter out the requested BAO formats
    AND bao.label NOT IN (
        'cell-based format', 
        'tissue-based format', 
        'cell membrane format'
    )
ORDER BY  
    md.chembl_id, 
    ass.confidence_score DESC, -- Prioritize most confident data
    act.standard_value ASC;



	--Filtered to include only single-cell format, assay format, and confidence score
	SELECT 
    md.chembl_id AS molecule_id,
    md.pref_name AS molecule_name,
    cs.canonical_smiles,
    act.activity_id,
    act.standard_type,
    act.standard_value,
    act.standard_units,
    act.pchembl_value,
    -- Target assignment confidence (0-9)
    ass.confidence_score, 
    -- Derived Action Type
    CASE 
        WHEN ass.description ILIKE '%ANTAGONIST%' THEN 'ANTAGONIST'
        WHEN ass.description ILIKE '%AGONIST%' AND ass.description NOT ILIKE '%ANTAGONIST%' THEN 'AGONIST'
        WHEN ass.description ILIKE '%INHIBITOR%' THEN 'INHIBITOR'
        WHEN ass.description ILIKE '%BINDING%' THEN 'BINDING AGENT'
        WHEN ass.description ILIKE '%DEGRADER%' OR ass.description ILIKE '%PROTAC%' THEN 'DEGRADER'
        ELSE 'OTHER/MODULATOR'
    END AS action_type,
    bao.label AS bao_format_label,
    ass.description AS assay_details,
    td.pref_name AS target_name
FROM 
    target_dictionary td
JOIN 
    assays ass ON td.tid = ass.tid
JOIN 
    activities act ON ass.assay_id = act.assay_id
JOIN 
    molecule_dictionary md ON act.molregno = md.molregno
JOIN 
    compound_structures cs ON md.molregno = cs.molregno
JOIN 
    bioassay_ontology bao ON ass.bao_format = bao.bao_id
WHERE 
    td.chembl_id = 'CHEMBL1871'
    AND td.target_type = 'SINGLE PROTEIN'
    AND act.standard_type = 'IC50'
    AND act.standard_value IS NOT NULL
    AND md.max_phase IN (1,2,3)
    
    -- Filter out cellular/tissue noise as requested
    AND bao.label NOT IN (
        'cell-based format', 
        'tissue-based format', 
        'cell membrane format'
    )
ORDER BY 
    md.chembl_id, 
    ass.confidence_score DESC, -- Prioritize most confident data
    act.standard_value ASC;