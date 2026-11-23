-- ============================================================================
-- SCHEMA CHO ONLINE JUDGE (PHIÊN BẢN VPS LINUX CHẠY ĐỘC LẬP)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  custom_templates JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.contests (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  is_visible BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.problems (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  statement TEXT DEFAULT '',
  input_format TEXT DEFAULT '',
  output_format TEXT DEFAULT '',
  constraints TEXT DEFAULT '',
  sample_input TEXT DEFAULT '',
  sample_output TEXT DEFAULT '',
  time_limit_ms INT NOT NULL DEFAULT 1000,
  memory_limit_mb INT NOT NULL DEFAULT 256,
  io_mode TEXT NOT NULL DEFAULT 'stdio' CHECK (io_mode IN ('stdio', 'file')),
  io_filename TEXT DEFAULT '',
  contest_id TEXT REFERENCES public.contests(id) ON DELETE CASCADE,
  problem_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.test_cases (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  problem_id TEXT NOT NULL REFERENCES public.problems(id) ON DELETE CASCADE,
  test_order INT NOT NULL DEFAULT 1,
  input_data TEXT NOT NULL DEFAULT '',
  expected_output TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_test_cases_problem_order
  ON public.test_cases(problem_id, test_order);

CREATE TABLE IF NOT EXISTS public.submissions (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  problem_id TEXT NOT NULL REFERENCES public.problems(id) ON DELETE CASCADE,
  contest_id TEXT REFERENCES public.contests(id) ON DELETE SET NULL,
  username TEXT NOT NULL,
  language TEXT NOT NULL,
  source_code TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Pending',
  verdict TEXT DEFAULT 'Pending',
  exec_time_ms INT DEFAULT 0,
  memory_kb INT DEFAULT 0,
  compile_message TEXT DEFAULT '',
  test_results JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Index chuyên biệt cho VPS Worker lấy bài Pending siêu tốc
CREATE INDEX IF NOT EXISTS idx_submissions_pending_queue
  ON public.submissions(id ASC)
  WHERE status = 'Pending';

CREATE TABLE IF NOT EXISTS public.system_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Hàm RPC nhận bài nộp nguyên tử (Atomic Queue) cho VPS Worker
CREATE OR REPLACE FUNCTION public.claim_next_submission()
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  next_id BIGINT;
BEGIN
  SELECT id INTO next_id
  FROM public.submissions
  WHERE status = 'Pending'
  ORDER BY id ASC
  FOR UPDATE SKIP LOCKED
  LIMIT 1;

  IF next_id IS NOT NULL THEN
    UPDATE public.submissions
    SET status = 'Judging'
    WHERE id = next_id;
  END IF;

  RETURN next_id;
END;
$$;

ALTER PUBLICATION supabase_realtime ADD TABLE public.submissions;
