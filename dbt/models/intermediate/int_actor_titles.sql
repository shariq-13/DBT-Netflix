{{ config(
    materialized='incremental',
    unique_key='actor_title_key',
    incremental_strategy='merge'
) }}

with source as (

    select
        person_id,
        trim(title_id) as title_id,
        trim(person_name) as person_name
    from {{ ref('stg_credits') }}
    where role = 'ACTOR'

),

deduped as (

    select
        md5(
            concat_ws(
                '|',
                coalesce(cast(person_id as varchar), ''),
                coalesce(title_id, '')
            )
        ) as actor_title_key,

        person_id,
        title_id,
        person_name

    from source

    qualify row_number() over (
        partition by person_id, title_id
        order by person_name
    ) = 1

)

select
    actor_title_key,
    person_id,
    title_id,
    person_name

from deduped

{% if is_incremental() %}

where not exists (

    select 1
    from {{ this }} existing

    where existing.actor_title_key = deduped.actor_title_key

)

{% endif %}