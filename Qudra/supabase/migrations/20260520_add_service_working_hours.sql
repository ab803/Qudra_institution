-- This migration adds structured working hour fields to services
-- so the institution can define daily working days and times.

ALTER TABLE public.services
ADD COLUMN IF NOT EXISTS working_days jsonb NOT NULL DEFAULT '[]'::jsonb;

-- This column stores the daily working start time for the service.
ALTER TABLE public.services
ADD COLUMN IF NOT EXISTS working_start_time time without time zone;

-- This column stores the daily working end time for the service.
ALTER TABLE public.services
ADD COLUMN IF NOT EXISTS working_end_time time without time zone;

-- This block makes the slot-based booking mode the default for new services.
ALTER TABLE public.services
ALTER COLUMN booking_type SET DEFAULT 'instant_slot';

-- This block updates old request-based services to the new instant slot mode.
UPDATE public.services
SET booking_type = 'instant_slot'
WHERE booking_type IS NULL OR booking_type = 'request';