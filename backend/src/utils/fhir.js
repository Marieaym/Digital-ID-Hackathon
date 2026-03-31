import { v4 as uuidv4 } from "uuid";

export function buildMotherFhirBundle(mother, visits) {
  const patientId = `patient-${mother.id}`;
  const bundleId = uuidv4();

  const patient = {
    resourceType: "Patient",
    id: patientId,
    identifier: [
      { system: "urn:healthid:maternal-token", value: mother.maternal_token }
    ],
    name: [{ text: mother.full_name }],
    telecom: mother.phone ? [{ system: "phone", value: mother.phone }] : [],
    extension: [
      { url: "urn:healthid:region", valueString: mother.region || "" },
      { url: "urn:healthid:age", valueInteger: mother.age }
    ]
  };

  const entries = [
    { fullUrl: `urn:uuid:${patientId}`, resource: patient }
  ];

  for (const v of visits) {
    const encId = `enc-${v.id}`;
    entries.push({
      fullUrl: `urn:uuid:${encId}`,
      resource: {
        resourceType: "Encounter",
        id: encId,
        status: "finished",
        subject: { reference: `Patient/${patientId}` },
        period: { start: v.visit_date }
      }
    });

    // BP
    if (v.bp_systolic != null) {
      entries.push({
        fullUrl: `urn:uuid:obs-bp-${v.id}`,
        resource: {
          resourceType: "Observation",
          id: `obs-bp-${v.id}`,
          status: "final",
          category: [{ coding: [{ system: "http://terminology.hl7.org/CodeSystem/observation-category", code: "vital-signs" }] }],
          code: { text: "Systolic blood pressure" },
          subject: { reference: `Patient/${patientId}` },
          encounter: { reference: `Encounter/${encId}` },
          effectiveDateTime: v.visit_date,
          valueQuantity: { value: v.bp_systolic, unit: "mmHg" }
        }
      });
    }

    // Hemoglobin
    if (v.hb != null) {
      entries.push({
        fullUrl: `urn:uuid:obs-hb-${v.id}`,
        resource: {
          resourceType: "Observation",
          id: `obs-hb-${v.id}`,
          status: "final",
          code: { text: "Hemoglobin" },
          subject: { reference: `Patient/${patientId}` },
          encounter: { reference: `Encounter/${encId}` },
          effectiveDateTime: v.visit_date,
          valueQuantity: { value: v.hb, unit: "g/dL" }
        }
      });
    }

    // Risk "Condition" snapshot
    if (v.risk_json) {
      entries.push({
        fullUrl: `urn:uuid:cond-risk-${v.id}`,
        resource: {
          resourceType: "Condition",
          id: `cond-risk-${v.id}`,
          clinicalStatus: { text: "active" },
          code: { text: `Maternal risk: ${v.risk_json.level} (${v.risk_json.score})` },
          subject: { reference: `Patient/${patientId}` },
          recordedDate: v.visit_date,
          note: (v.risk_json.reasons || []).map(r => ({ text: r }))
        }
      });
    }
  }

  return {
    resourceType: "Bundle",
    id: bundleId,
    type: "collection",
    timestamp: new Date().toISOString(),
    entry: entries
  };
}
