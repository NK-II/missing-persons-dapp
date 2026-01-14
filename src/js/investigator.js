window.addEventListener("DOMContentLoaded", () => {
  const foundForm = document.getElementById("foundForm");
  const loadScheduleBtn = document.getElementById("loadScheduleBtn");
  const myScheduleDiv = document.getElementById("mySchedule");

  foundForm.addEventListener("submit", async (e) => {
    e.preventDefault();
    const caseId = document.getElementById("foundCaseId").value;
    const note = document.getElementById("foundNote").value;

    try {
      await contract.methods
        .reportFoundPerson(caseId, note)
        .send({ from: (await web3.eth.getAccounts())[0] });
      alert("Report sent to admin successfully");
    } catch (err) {
      console.error(err);
      alert("Failed to report");
    }
  });

  loadScheduleBtn.addEventListener("click", async () => {
    const address = (await web3.eth.getAccounts())[0];
    try {
      const schedule = await contract.methods.getInvestigatorSchedule(address).call();
      myScheduleDiv.innerHTML = schedule.length === 0
        ? "No appointments scheduled."
        : schedule.map(a => `Case ${a.caseId}, Slot: ${a.slot}`).join("<br>");
    } catch (err) {
      console.error(err);
      alert("Failed to load schedule");
    }
  });
});
