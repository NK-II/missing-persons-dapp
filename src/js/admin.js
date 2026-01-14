window.addEventListener("DOMContentLoaded", () => {
  const updateStatusForm = document.getElementById("updateStatusForm");
  const assignForm = document.getElementById("assignInvestigatorForm");
  const viewScheduleForm = document.getElementById("viewScheduleForm");
  const reviewFoundForm = document.getElementById("reviewFoundForm");

  updateStatusForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const caseId = document.getElementById("caseId").value;
    const newStatus = document.getElementById("newStatus").value;
    try {
      await contract.methods.updateStatus(caseId, newStatus).send({ from: (await web3.eth.getAccounts())[0] });
      alert("Status updated successfully");
    } catch (err) {
      console.error(err);
      alert("Failed to update status");
    }
  });

  assignForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const caseId = document.getElementById("assignCaseId").value;
    const investigator = document.getElementById("investigatorAddress").value;
    try {
      await contract.methods.assignInvestigator(caseId, investigator).send({ from: (await web3.eth.getAccounts())[0] });
      alert("Investigator assigned");
    } catch (err) {
      console.error(err);
      alert("Assignment failed");
    }
  });

  viewScheduleForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const address = document.getElementById("scheduleAddress").value;
    try {
      const appointments = await contract.methods.getInvestigatorSchedule(address).call();
      const resultDiv = document.getElementById("scheduleResult");
      resultDiv.innerHTML = appointments.length === 0
        ? "No appointments."
        : appointments.map(a => `Case ${a.caseId}, Slot: ${a.slot}`).join("<br>");
    } catch (err) {
      console.error(err);
      alert("Failed to fetch schedule");
    }
  });

  reviewFoundForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const caseId = document.getElementById("foundCaseId").value;
    try {
      await contract.methods.markAlertReviewed(caseId).send({ from: (await web3.eth.getAccounts())[0] });
      document.getElementById("foundAlertMsg").innerText = "Alert marked as reviewed.";
    } catch (err) {
      console.error(err);
      alert("Could not review alert");
    }
  });
});
