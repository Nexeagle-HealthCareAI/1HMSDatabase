-- Seeds a small starter set of consent templates per hospital.
-- Re-runnable: only inserts when (HospitalId, TypeCode, Language) has no active row.
-- @HospitalId must be passed by the caller (replace before execution, or wrap in a stored proc).

DECLARE @HospitalId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'; -- TODO: set per hospital
DECLARE @Now DATETIME2(3) = SYSUTCDATETIME();
DECLARE @SeededBy NVARCHAR(100) = 'SEED';

-- ───── General admission consent ─────────────────────────────────────────────
IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId AND TypeCode = N'GENERAL_ADMISSION' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId, N'GENERAL_ADMISSION', N'General Admission Consent', N'EN', 1,
N'<h3>General Consent for In-Patient Admission</h3>
<p>I, the undersigned, hereby authorize the medical and nursing staff of this hospital to provide such routine treatment, investigations, examinations, medications, and nursing care as my attending physician deems necessary during my hospital stay.</p>
<ul>
  <li>I understand that the practice of medicine and surgery is not an exact science and I acknowledge that no guarantees have been made as to the result of any treatment, examination, or procedure.</li>
  <li>I consent to the photography, electronic monitoring, and recording of my care, including images and video, for medical education, treatment, or quality assurance, subject to applicable privacy protections.</li>
  <li>I authorize the hospital to release my medical records as required by law, to insurance companies for payment of services, and to other healthcare providers involved in my care.</li>
  <li>I understand that I will be responsible for the cost of all services rendered, including those not covered by my insurance.</li>
</ul>
<p>I have read and understood the above. I have had the opportunity to ask questions and all my questions have been answered satisfactorily.</p>',
    1, @Now, @SeededBy, @Now, @SeededBy
  );
END
GO

-- ───── IV contrast consent ──────────────────────────────────────────────────
DECLARE @HospitalId2 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
DECLARE @Now2 DATETIME2(3) = SYSUTCDATETIME();

IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId2 AND TypeCode = N'IV_CONTRAST' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId2, N'IV_CONTRAST', N'Consent for IV Contrast Administration', N'EN', 1,
N'<h3>Informed Consent for Intravenous Contrast</h3>
<p>I have been informed that my doctor has recommended a diagnostic imaging study (CT / MRI / fluoroscopy / angiography) that requires the intravenous administration of contrast material.</p>
<h4>Benefits</h4>
<p>Contrast material can significantly improve the diagnostic quality of the study by highlighting blood vessels, organs, and abnormal tissues.</p>
<h4>Risks</h4>
<ul>
  <li>Mild reactions (~3%): warmth, metallic taste, brief nausea.</li>
  <li>Moderate reactions (~0.1%): hives, vomiting, bronchospasm.</li>
  <li>Severe reactions (rare, &lt;0.04%): anaphylaxis, low blood pressure, breathing difficulty, very rarely fatal.</li>
  <li>Possible kidney injury, especially with pre-existing renal disease, diabetes, dehydration, or NSAID use.</li>
  <li>Extravasation at the IV site, which can cause local swelling and discomfort.</li>
  <li>For gadolinium-based contrast (MRI): rare risk of Nephrogenic Systemic Fibrosis (NSF) in patients with severe renal impairment.</li>
</ul>
<h4>Alternatives</h4>
<p>The study can be performed without contrast, but image quality may be significantly reduced and the diagnostic question may not be fully answered. Alternative imaging modalities may be available with their own risks and benefits.</p>
<p>I confirm that I have been asked about and have disclosed any history of allergic reactions, asthma, kidney disease, diabetes, or previous contrast reactions. I have had the opportunity to ask questions and all my questions have been answered.</p>',
    1, @Now2, N'SEED', @Now2, N'SEED'
  );
END
GO

-- ───── Blood transfusion consent ────────────────────────────────────────────
DECLARE @HospitalId3 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
DECLARE @Now3 DATETIME2(3) = SYSUTCDATETIME();

IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId3 AND TypeCode = N'BLOOD_TRANSFUSION' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId3, N'BLOOD_TRANSFUSION', N'Consent for Blood / Blood-Product Transfusion', N'EN', 1,
N'<h3>Informed Consent for Blood and Blood Product Transfusion</h3>
<p>My doctor has informed me that I may require a transfusion of blood or blood products (red cells, plasma, platelets, cryoprecipitate) as part of my treatment.</p>
<h4>Benefits</h4>
<p>Transfusion can be life-saving for severe anaemia, active bleeding, clotting deficiencies, or low platelet counts. It is often the only effective treatment for these conditions.</p>
<h4>Risks</h4>
<ul>
  <li>Allergic and febrile reactions (mild to severe).</li>
  <li>Transfusion-related acute lung injury (TRALI) — rare.</li>
  <li>Transfusion-associated circulatory overload (TACO).</li>
  <li>Acute and delayed haemolytic reactions due to blood-group incompatibility.</li>
  <li>Transmission of infections (HIV, hepatitis B / C, syphilis, malaria, others) — extremely low risk due to mandatory donor screening.</li>
  <li>Alloimmunization affecting future transfusions or pregnancy.</li>
</ul>
<h4>Alternatives</h4>
<p>Depending on the clinical situation, alternatives may include iron therapy, erythropoietin, autologous transfusion, intra-operative cell salvage, or refusing transfusion (which carries its own serious risks).</p>
<p>I confirm that the risks, benefits, and alternatives have been explained to me in a language I understand. I have had the opportunity to ask questions and all my questions have been answered.</p>',
    1, @Now3, N'SEED', @Now3, N'SEED'
  );
END
GO

-- ───── Discharge advice & consent ───────────────────────────────────────────
DECLARE @HospitalId4 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
DECLARE @Now4 DATETIME2(3) = SYSUTCDATETIME();

IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId4 AND TypeCode = N'DISCHARGE' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId4, N'DISCHARGE', N'Discharge Advice & Consent', N'EN', 1,
N'<h3>Discharge Advice &amp; Consent</h3>
<p>I confirm that my/the patient''s diagnosis, the treatment given during this admission, and the condition at the time of discharge have been explained to me in a language I understand.</p>
<ul>
  <li>I have been given the discharge medications, dosage instructions, diet and activity advice, and follow-up plan in writing.</li>
  <li>I have been told the warning signs and symptoms for which I should seek immediate medical attention or return to the hospital.</li>
  <li>I have had the opportunity to ask questions about my/the patient''s condition and ongoing care, and all my questions have been answered satisfactorily.</li>
  <li>I agree to the patient being discharged from the hospital''s care at this time.</li>
</ul>
<p>I understand that continued follow-up as advised is important for a full recovery.</p>',
    1, @Now4, N'SEED', @Now4, N'SEED'
  );
END
GO

-- ───── Leave Against Medical Advice (LAMA) consent ──────────────────────────
DECLARE @HospitalId5 UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000';
DECLARE @Now5 DATETIME2(3) = SYSUTCDATETIME();

IF NOT EXISTS (
  SELECT 1 FROM dbo.ConsentTemplate
  WHERE HospitalId = @HospitalId5 AND TypeCode = N'LAMA' AND [Language] = N'EN' AND IsActive = 1
)
BEGIN
  INSERT INTO dbo.ConsentTemplate (HospitalId, TypeCode, Title, [Language], Version, BodyHtml, IsActive, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy)
  VALUES (
    @HospitalId5, N'LAMA', N'Leave Against Medical Advice (LAMA) Consent', N'EN', 1,
N'<h3>Leave Against Medical Advice</h3>
<p>I am voluntarily choosing to leave the hospital, or to remove the patient from the hospital, before treatment has been completed and against the advice of the treating doctor(s).</p>
<h4>Acknowledgement of risk</h4>
<ul>
  <li>I have been informed of my/the patient''s current diagnosis and the treatment that is still recommended.</li>
  <li>I have been explained the risks of leaving before treatment is complete, including but not limited to worsening of the condition, complications, permanent disability, or death.</li>
  <li>I have had the opportunity to ask questions about these risks, and all my questions have been answered.</li>
  <li>I understand I may return to this hospital for further care at any time, and that a follow-up plan/referral has been offered to me.</li>
</ul>
<h4>Release</h4>
<p>I hereby release the hospital, its doctors, and its staff from all liability for any consequences that may result from my/the patient leaving against medical advice.</p>',
    1, @Now5, N'SEED', @Now5, N'SEED'
  );
END
GO
