--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.habitacions DROP CONSTRAINT IF EXISTS habitacions_hotel_id_foreign;
DROP INDEX IF EXISTS public.personal_access_tokens_tokenable_type_tokenable_id_index;
DROP INDEX IF EXISTS public.hotels_nombre_index;
DROP INDEX IF EXISTS public.hotels_ciudad_index;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_unique;
ALTER TABLE IF EXISTS ONLY public.habitacions DROP CONSTRAINT IF EXISTS unique_habitacion_config;
ALTER TABLE IF EXISTS ONLY public.personal_access_tokens DROP CONSTRAINT IF EXISTS personal_access_tokens_token_unique;
ALTER TABLE IF EXISTS ONLY public.personal_access_tokens DROP CONSTRAINT IF EXISTS personal_access_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.password_reset_tokens DROP CONSTRAINT IF EXISTS password_reset_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.migrations DROP CONSTRAINT IF EXISTS migrations_pkey;
ALTER TABLE IF EXISTS ONLY public.hotels DROP CONSTRAINT IF EXISTS hotels_pkey;
ALTER TABLE IF EXISTS ONLY public.hotels DROP CONSTRAINT IF EXISTS hotels_nombre_unique;
ALTER TABLE IF EXISTS ONLY public.hotels DROP CONSTRAINT IF EXISTS hotels_nit_unique;
ALTER TABLE IF EXISTS ONLY public.habitacions DROP CONSTRAINT IF EXISTS habitacions_pkey;
ALTER TABLE IF EXISTS ONLY public.failed_jobs DROP CONSTRAINT IF EXISTS failed_jobs_uuid_unique;
ALTER TABLE IF EXISTS ONLY public.failed_jobs DROP CONSTRAINT IF EXISTS failed_jobs_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.personal_access_tokens ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.migrations ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.hotels ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.habitacions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.failed_jobs ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.personal_access_tokens_id_seq;
DROP TABLE IF EXISTS public.personal_access_tokens;
DROP TABLE IF EXISTS public.password_reset_tokens;
DROP SEQUENCE IF EXISTS public.migrations_id_seq;
DROP TABLE IF EXISTS public.migrations;
DROP SEQUENCE IF EXISTS public.hotels_id_seq;
DROP TABLE IF EXISTS public.hotels;
DROP SEQUENCE IF EXISTS public.habitacions_id_seq;
DROP TABLE IF EXISTS public.habitacions;
DROP SEQUENCE IF EXISTS public.failed_jobs_id_seq;
DROP TABLE IF EXISTS public.failed_jobs;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: habitacions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.habitacions (
    id bigint NOT NULL,
    hotel_id bigint NOT NULL,
    tipo_habitacion character varying(255) NOT NULL,
    acomodacion character varying(255) NOT NULL,
    cantidad integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT habitacions_acomodacion_check CHECK (((acomodacion)::text = ANY (ARRAY[('SENCILLA'::character varying)::text, ('DOBLE'::character varying)::text, ('TRIPLE'::character varying)::text, ('CUADRUPLE'::character varying)::text]))),
    CONSTRAINT habitacions_tipo_habitacion_check CHECK (((tipo_habitacion)::text = ANY (ARRAY[('ESTANDAR'::character varying)::text, ('JUNIOR'::character varying)::text, ('SUITE'::character varying)::text])))
);


--
-- Name: habitacions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.habitacions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: habitacions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.habitacions_id_seq OWNED BY public.habitacions.id;


--
-- Name: hotels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hotels (
    id bigint NOT NULL,
    nombre character varying(255) NOT NULL,
    direccion character varying(255) NOT NULL,
    ciudad character varying(255) NOT NULL,
    nit character varying(255) NOT NULL,
    numero_max_habitaciones integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: hotels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hotels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hotels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hotels_id_seq OWNED BY public.hotels.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: habitacions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.habitacions ALTER COLUMN id SET DEFAULT nextval('public.habitacions_id_seq'::regclass);


--
-- Name: hotels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels ALTER COLUMN id SET DEFAULT nextval('public.hotels_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: habitacions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (1, 1, 'ESTANDAR', 'SENCILLA', 25, '2025-06-09 02:23:10', '2025-06-09 02:23:10');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (2, 1, 'JUNIOR', 'TRIPLE', 12, '2025-06-09 02:23:10', '2025-06-09 02:23:10');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (3, 1, 'ESTANDAR', 'DOBLE', 5, '2025-06-09 02:23:10', '2025-06-09 02:23:10');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (4, 2, 'ESTANDAR', 'SENCILLA', 30, '2025-06-09 03:49:20', '2025-06-09 03:49:20');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (5, 2, 'JUNIOR', 'TRIPLE', 20, '2025-06-09 03:49:20', '2025-06-09 03:49:20');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (6, 2, 'SUITE', 'DOBLE', 10, '2025-06-09 03:49:20', '2025-06-09 03:49:20');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (7, 3, 'ESTANDAR', 'DOBLE', 15, '2025-06-09 03:49:58', '2025-06-09 03:49:58');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (8, 3, 'JUNIOR', 'CUADRUPLE', 15, '2025-06-09 03:49:58', '2025-06-09 03:49:58');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (9, 3, 'SUITE', 'TRIPLE', 5, '2025-06-09 03:49:58', '2025-06-09 03:49:58');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (10, 4, 'ESTANDAR', 'SENCILLA', 20, '2025-06-09 03:50:30', '2025-06-09 03:50:30');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (11, 4, 'SUITE', 'SENCILLA', 8, '2025-06-09 03:50:30', '2025-06-09 03:50:30');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (12, 5, 'ESTANDAR', 'DOBLE', 25, '2025-06-09 03:50:41', '2025-06-09 03:50:41');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (13, 5, 'JUNIOR', 'TRIPLE', 15, '2025-06-09 03:50:41', '2025-06-09 03:50:41');


--
-- Data for Name: hotels; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.hotels (id, nombre, direccion, ciudad, nit, numero_max_habitaciones, created_at, updated_at) VALUES (1, 'Decameron Cartagena', 'Calle 23 58-25', 'Cartagena', '12345678-9', 42, '2025-06-08 16:39:30', '2025-06-08 16:39:30');
INSERT INTO public.hotels (id, nombre, direccion, ciudad, nit, numero_max_habitaciones, created_at, updated_at) VALUES (2, 'Decameron San Andrés', 'Avenida Colombia No. 1-19', 'San Andrés', '98765432-1', 60, '2025-06-09 03:48:25', '2025-06-09 03:48:25');
INSERT INTO public.hotels (id, nombre, direccion, ciudad, nit, numero_max_habitaciones, created_at, updated_at) VALUES (3, 'Decameron Marazul', 'Km 14 Vía San Andrés', 'San Andrés', '11223344-5', 35, '2025-06-09 03:48:33', '2025-06-09 03:48:33');
INSERT INTO public.hotels (id, nombre, direccion, ciudad, nit, numero_max_habitaciones, created_at, updated_at) VALUES (4, 'Decameron Barú', 'Playa Blanca, Isla Barú', 'Cartagena', '55667788-9', 28, '2025-06-09 03:48:40', '2025-06-09 03:48:40');
INSERT INTO public.hotels (id, nombre, direccion, ciudad, nit, numero_max_habitaciones, created_at, updated_at) VALUES (5, 'Decameron Los Cocos', 'Carrera 3 No. 8-60', 'Rincón del Mar', '99887766-3', 50, '2025-06-09 03:48:47', '2025-06-09 03:48:47');


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.migrations (id, migration, batch) VALUES (1, '2014_10_12_000000_create_users_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (2, '2014_10_12_100000_create_password_reset_tokens_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (3, '2019_08_19_000000_create_failed_jobs_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (4, '2019_12_14_000001_create_personal_access_tokens_table', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES (5, '2025_06_08_163238_create_hotels_table', 2);
INSERT INTO public.migrations (id, migration, batch) VALUES (6, '2025_06_08_163249_create_habitacions_table', 2);


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: habitacions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.habitacions_id_seq', 13, true);


--
-- Name: hotels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hotels_id_seq', 5, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 6, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: habitacions habitacions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.habitacions
    ADD CONSTRAINT habitacions_pkey PRIMARY KEY (id);


--
-- Name: hotels hotels_nit_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_nit_unique UNIQUE (nit);


--
-- Name: hotels hotels_nombre_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_nombre_unique UNIQUE (nombre);


--
-- Name: hotels hotels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hotels
    ADD CONSTRAINT hotels_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: habitacions unique_habitacion_config; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.habitacions
    ADD CONSTRAINT unique_habitacion_config UNIQUE (hotel_id, tipo_habitacion, acomodacion);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: hotels_ciudad_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hotels_ciudad_index ON public.hotels USING btree (ciudad);


--
-- Name: hotels_nombre_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hotels_nombre_index ON public.hotels USING btree (nombre);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: habitacions habitacions_hotel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.habitacions
    ADD CONSTRAINT habitacions_hotel_id_foreign FOREIGN KEY (hotel_id) REFERENCES public.hotels(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

