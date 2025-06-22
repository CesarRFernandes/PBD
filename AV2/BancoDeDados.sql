create table cliente (
  id bigint primary key generated always as identity,
  nome text not null,
  cpf text not null unique,
  telefone text,
  cep text,
  data_nascimento date
);

create table quarto (
  id bigint primary key generated always as identity,
  numero text not null, --numero do quarto
  capacidade int check (capacidade in (4, 8, 12)), --capacidade de pessoas no quarto
  banheiro boolean, --tem ou não banheiro  
  janela boolean, --tem ou não janela
  descricao text  --detalhes adicionais do quarto pertinentes à reserva
);

create table vaga (
  id bigint primary key generated always as identity,
  quarto_id bigint references quarto (id),
  cama text, --tipo da cama se é de cima ou de baixo
  local text, --se é perto ou longe da janela ou porta
  descricao text  --detalhes adicionais do quarto pertinentes à reserva
);

create table reserva (
  id bigint primary key generated always as identity,
  cliente_id bigint references cliente (id),
  vaga_id bigint references vaga (id),
  data_chegada date,
  data_saida date,
  total_reserva numeric(10, 2),
  status text  --status da reserva, se está pendente, confirmado ou cancelado
);

create table pagamento (
  id bigint primary key generated always as identity,
  reserva_id bigint references reserva (id),
  valor numeric(10, 2),
  data_transacao date,
  status text, --status do pagamento, se está pendente, realizado ou não aprovado
  tipo_pagamento text --forma de pagamento
);
