import { makeStyles } from "@mui/styles";
import { alpha } from "@mui/material/styles";

export const useStyles = makeStyles((theme) => ({
  root: {
    display: "flex",
    flexWrap: "wrap",
  },
  textField: {
    marginLeft: theme.spacing(1),
    marginRight: theme.spacing(1),
  },
  gridRoot: {
    flexGrow: 1,
  },
  gridPaper: {
    padding: theme.spacing(2),
    textAlign: "center",
    color: theme.palette.text.secondary,
    height: "50px",
  },
  input: {
    background: alpha(theme.palette.common.white, 0.1),
    border: `1px solid ${alpha(theme.palette.common.white, 0.2)}`,
    borderRadius: theme.shape.borderRadius,
    padding: theme.spacing(1, 2),
    color: theme.palette.text.primary,
    "&:focus": {
      borderColor: theme.palette.primary.main,
      outline: "none",
    },
  },
  button: {
    textTransform: "none" as const,
    fontWeight: 600,
    borderRadius: theme.shape.borderRadius,
  },
}));
