const express = require("express");
const cors = require("cors");
require("dotenv").config();
const apiRoutes = require("./routes/api");

const app = express();
app.use(cors());

// [ĐÃ NỚI RỘNG BỘ NHỚ ĐỂ NHẬN ĐƯỢC ẢNH & FILE PDF NẶNG]:
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));

app.use("/api", apiRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 SentiFlow Backend đang chạy tại: http://localhost:${PORT}`);
});
