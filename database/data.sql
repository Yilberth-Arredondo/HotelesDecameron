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

--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: hotels; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.hotels (id, nombre, direccion, ciudad, nit, numero_max_habitaciones, created_at, updated_at) VALUES (1, 'Decameron Cartagena', 'Calle 23 58-25', 'Cartagena', '12345678-9', 42, '2025-06-08 16:39:30', '2025-06-08 16:39:30');


--
-- Data for Name: habitacions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (1, 1, 'ESTANDAR', 'SENCILLA', 25, '2025-06-09 02:23:10', '2025-06-09 02:23:10');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (2, 1, 'JUNIOR', 'TRIPLE', 12, '2025-06-09 02:23:10', '2025-06-09 02:23:10');
INSERT INTO public.habitacions (id, hotel_id, tipo_habitacion, acomodacion, cantidad, created_at, updated_at) VALUES (3, 1, 'ESTANDAR', 'DOBLE', 5, '2025-06-09 02:23:10', '2025-06-09 02:23:10');


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

SELECT pg_catalog.setval('public.habitacions_id_seq', 3, true);


--
-- Name: hotels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hotels_id_seq', 1, true);


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
-- PostgreSQL database dump complete
--

